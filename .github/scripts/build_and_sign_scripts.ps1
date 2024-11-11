# Set environment variables
$services = $env:SCRIPT_SERVICES -split ','
$workspace = $env:GITHUB_WORKSPACE
$replaceKey = $env:AGENT_SECRET_PREFIX
$signCert = $env:SIGN_CERT
$signKey = $env:SIGN_KEY
$signContainer = $env:SIGN_CONTAINER
$url = $env:CM_API

Write-Output "Services: $services"
Write-Output "Workspace: $workspace"
Write-Output "URL: $url"

# Parse JSON from CM_PUB_AUTH
$auth = $env:CM_PUB_AUTH | ConvertFrom-Json

# Load versions.json
$versionsJsonPath = Join-Path $workspace "versions.json"
Write-Output "Loading versions.json from: $versionsJsonPath"
$versionsContent = Get-Content -Path $versionsJsonPath -Raw | ConvertFrom-Json
Write-Output "Versions: $versionsContent"

# Set up headers
Write-Output "Setting up headers..."
$headers = @{
    "publisher-key" = $auth.key
    "publisher-id"  = $auth.id
}
Write-Output "Headers set: $headers"

# Upsert Master Version
$masterChangelogPath = Join-Path $workspace "CHANGELOG.md"
Write-Output "Loading master changelog from: $masterChangelogPath"
$masterChangelog = Get-Content -Path $masterChangelogPath -Raw

Write-Output "Preparing master version data..."
$masterVersionData = @{
    changelog = $masterChangelog
    version_name = $versionsContent.version
} | ConvertTo-Json -Depth 10

Write-Output "Master version data prepared: $masterVersionData"

Write-Output "Attempting to upsert Master Version..."

try {
    $response = Invoke-RestMethod -Uri "$url/master-version" -Method Post -Headers $headers -ContentType 'application/json' -Body $masterVersionData
    $masterVersionId = $response.Trim()
    Write-Output "Master Version ID: $masterVersionId"
}
catch {
    Write-Error "Error in Master Version POST request: $_"
    throw $_
}

Write-Output "Master Version upserted successfully."


# Upsert Component Version, Scripts, and Files
foreach ($service in $services) {
    Write-Output "Processing service: $service"
    $path = $service -replace "-", "/"
    $servicePath = "$workspace/$path"

    # Add specific pre-build steps here
    if ($service -eq "agent-service") {
        Set-Location "$servicePath/config"
        (Get-Content const.go) | Foreach-Object { $_ -replace 'const REPLACE_KEY string = ""', "const REPLACE_KEY string = '$replaceKey'" } | Set-Content const.go
    }

    Set-Location $servicePath

    # Upsert Component Version
    $changelogPath = Join-Path $workspace $service "CHANGELOG.md"
    $changelog = Get-Content -Path $changelogPath -Raw

    $readmePath = Join-Path $workspace $service "README.md"
    $readme = Get-Content -Path $readmePath -Raw

    $componentVersionData = @{
        changelog = $changelog
        description = $readme
        editions = @("Community", "Enterprise")
        master_version_id = $masterVersionId
        name = $service
        version_name = $versionsContent.$service
    } | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod -Uri "$url/component-version" -Method Post -Headers $headers -ContentType 'application/json' -Body $componentVersionData
        $componentVersionId = $response.Trim()
        Write-Output "Component Version ID: $componentVersionId"
    }
    catch {
        Write-Error "Error in Component Version POST request: $_"
        throw $_
    }

    # Upsert Files and dependencies
    $filesPath = Join-Path $servicePath "files.json"
    $filesContent = Get-Content -Path $filesPath -Raw | ConvertFrom-Json
    foreach ($file in $filesContent) {
        $fileName = $file.name
        $filePath = if ($fileName -like "*.zip" -or $fileName -like "*.yaml" -or $fileName -like "*.yml" -or $fileName -like "*.json") {
            Join-Path $servicePath "dependencies" $fileName
        } else {
            # Build and sign the file if it's not a dependency
            $env:GOOS = $file.os
            $env:GOARCH = $file.arch
            Write-Output "Building $fileName for $($file.os) $($file.arch)..."
            go build -o $fileName -v .

            if ($file.os -eq "windows") {
                Write-Output "Signing $fileName..."
                signtool sign /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 /f "$signCert" /csp "eToken Base Cryptographic Provider" /k "[{{$signKey}}]=$signContainer" $fileName
            }
            Join-Path $servicePath $fileName
        }

        # Prepare file data
        $fileData = @{
            version_id = $componentVersionId
            name = $fileName
            is_binary = $file.is_binary
            destination_path = $file.destination_path
            os = $file.os
            arch = $file.arch
            replace_previous = $file.replace_previous
        } | ConvertTo-Json -Depth 10

        # Prepare multipart form data
        $boundary = "----WebKitFormBoundary" + [System.Guid]::NewGuid().ToString("N")
        $contentType = "multipart/form-data; boundary=$boundary"

        # Build the multipart form data as a string
        $fileContent = [System.IO.File]::ReadAllBytes($filePath)
        $fileContentEncoded = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetString($fileContent)

        $multipartData = "--$boundary`r`n"
        $multipartData += "Content-Disposition: form-data; name=`"data`"`r`n"
        $multipartData += "Content-Type: application/json`r`n`r`n"
        $multipartData += "$fileData`r`n"
        $multipartData += "--$boundary`r`n"
        $multipartData += "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"`r`n"
        $multipartData += "Content-Type: application/octet-stream`r`n`r`n"
        $multipartData += "$fileContentEncoded`r`n"
        $multipartData += "--$boundary--`r`n"

        # Convert the multipart data to bytes
        $multipartBytes = [System.Text.Encoding]::UTF8.GetBytes($multipartData)

        # Create a WebRequest object
        $webRequest = [System.Net.HttpWebRequest]::Create("$url/upload-file")
        $webRequest.Method = "POST"
        $webRequest.ContentType = $contentType
        $webRequest.Headers.Add("publisher-key", $auth.key)
        $webRequest.Headers.Add("publisher-id", $auth.id)
        $webRequest.ContentLength = $multipartBytes.Length

        # Write the multipart data to the request stream
        $requestStream = $webRequest.GetRequestStream()
        $requestStream.Write($multipartBytes, 0, $multipartBytes.Length)
        $requestStream.Close()

        try {
            $response = $webRequest.GetResponse()
            $responseStream = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($responseStream)
            $responseContent = $reader.ReadToEnd()
            Write-Output "Upload Response for ${fileName}:"
            Write-Output $responseContent
            $reader.Close()
            $responseStream.Close()
            $response.Close()
        }
        catch {
            $errorResponse = $_.Exception.Response
            if ($errorResponse -ne $null) {
                $responseStream = $errorResponse.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($responseStream)
                $errorContent = $reader.ReadToEnd()
                Write-Error "HTTP Request to /upload-file failed: $($errorResponse.StatusCode): $errorContent"
                $reader.Close()
                $responseStream.Close()
            }
            else {
                Write-Error "Error in file upload for ${fileName}: $_"
            }
            throw $_
        }
    }
}

Set-Location $workspace
Remove-Item -Path "./*" -Recurse -Force
