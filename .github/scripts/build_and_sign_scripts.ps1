# Set environment variables
$services = $env:SCRIPT_SERVICES -split ','
$workspace = $env:GITHUB_WORKSPACE
$replaceKey = $env:AGENT_SECRET_PREFIX
$signCert = $env:SIGN_CERT
$signKey = $env:SIGN_KEY
$signContainer = $env:SIGN_CONTAINER
$url = $env:CM_API

# Parse JSON from CM_PUB_AUTH
&auth = $env:CM_PUB_AUTH | ConvertFrom-Json

# Load versions.json
$versionsJsonPath = Join-Path $workspace "versions.json"
$versionsContent = Get-Content -Path $versionsJsonPath -Raw | ConvertFrom-Json

# Create a http client
$httpClient = New-Object System.Net.Http.HttpClient
$httpClient.DefaultRequestHeaders.Add("publisher-key", $auth.key)
$httpClient.DefaultRequestHeaders.Add("publisher-id", $auth.id)

# Upsert Master Version
$masterChangelogPath = Join-Path $workspace "CHANGELOG.md"
$masterChangelog = Get-Content -Path $masterChangelogPath -Raw

$masterVersionData = @{
    changelog = $masterChangelog
    version_name = $versionsContent.version
} | ConvertTo-Json -Depth 10

try {
    $response = httpclient.PostAsync("$url/master-version", [System.Net.Http.StringContent]::new($masterVersionData, [System.Text.Encoding]::UTF8, "application/json")).Result
    if ($response.IsSuccessStatusCode) {
        $masterVersionId = $response.Content.ReadAsStringAsync().Result.Trim()
        Write-Output "Master Version ID: $masterVersionId"
    }
    else {
        $errorContent = $response.Content.ReadAsStringAsync().Result
        throw "HTTP Request to /master-version failed: $($response.StatusCode): $errorContent"
    }
}
catch {
    Write-Error "Error in Master Version POST request: $_"
    throw $_
}

# Upsert Component Version, Scripts and Files
foreach ($service in $services) {
    $path = $service -replace "-", "/"
    $servicePath = "$workspace/$path"

    # Add especific pre-build steps here
    if ($service -eq "agent-service") {
        cd $servicePath/config
        (Get-Content const.go) | Foreach-Object { $_ -replace 'const REPLACE_KEY string = ""', 'const REPLACE_KEY string = "$replaceKey"' } | Set-Content const.go
    }

    cd $servicePath

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
        name        = $service
        version_name = $versionsContent.$service        
    } | ConvertTo-Json -Depth 10

    try {
        $response = $httpClient.PostAsync("$url/component-version", [System.Net.Http.StringContent]::new($componentVersionData, [System.Text.Encoding]::UTF8, "application/json")).Result
        if ($response.IsSuccessStatusCode) {
            $componentVersionId = $response.Content.ReadAsStringAsync().Result.Trim()
            Write-Output "Component Version ID: $componentVersionId"
        }
        else {
            $errorContent = $response.Content.ReadAsStringAsync().Result
            throw "HTTP Request to /component-version failed: $($response.StatusCode): $errorContent"
        }
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
            # Buld and sign the file if it's not a dependency
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
        
        # Prepare files for upload
        $fileData = @{
            version_id = $componentVersionId
            name = $fileName
            is_binary = $file.is_binary
            destination_path = $file.destination_path
            os = $file.os
            arch = $file.arch
            replace_previous = $file.replace_previous
        } | ConvertTo-Json -Depth 10

        $boundary = [System.Guid]::NewGuid().ToString()
        $multipartContent = New-Object System.Net.Http.MultipartFormDataContent($boundary)
        $dataContent = New-Object System.Net.Http.StringContent($fileData, [System.Text.Encoding]::UTF8, "application/json")
        $multipartContent.Add($dataContent, "data")

        $fileStream = [System.IO.File]::OpenRead($filePath)
        $streamContent = New-Object System.Net.Http.StreamContent($fileStream)
        $streamContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/octet-stream")
        $multipartContent.Add($streamContent, "file", $fileName)

        try {
            $response = $httpClient.PostAsync("$url/upload-file", $multipartContent).Result
            if ($response.IsSuccessStatusCode) {
                $responseContent = $response.Content.ReadAsStringAsync().Result
                Write-Output "Upload Response for $fileName:"
                Write-Output $responseContent
            }
            else {
                $errorContent = $response.Content.ReadAsStringAsync().Result
                throw "HTTP Request to /upload-file failed: $($response.StatusCode): $errorContent"
            }
        }
        catch {
            Write-Error "Error in file upload for $fileName: $_"
            throw $_
        }
    }    
}

cd $workspace
Remove-Item -Path "./*" -Recurse -Force