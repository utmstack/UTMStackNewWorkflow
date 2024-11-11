import os
import json
import subprocess
import requests
import uuid
import shutil

# Set environment variables
services = os.environ.get('SCRIPT_SERVICES', '').split(',')
workspace = os.environ.get('GITHUB_WORKSPACE', '')
replace_key = os.environ.get('AGENT_SECRET_PREFIX', '')
sign_cert = os.environ.get('SIGN_CERT', '')
sign_key = os.environ.get('SIGN_KEY', '')
sign_container = os.environ.get('SIGN_CONTAINER', '')
url = os.environ.get('CM_API', '')

print(f"Services: {services}")
print(f"Workspace: {workspace}")
print(f"URL: {url}")

# Parse JSON from CM_PUB_AUTH
cm_pub_auth_json = os.environ.get('CM_PUB_AUTH', '{}')
auth = json.loads(cm_pub_auth_json)

# Load versions.json
versions_json_path = os.path.join(workspace, 'versions.json')
print(f"Loading versions.json from: {versions_json_path}")
with open(versions_json_path, 'r') as f:
    versions_content = json.load(f)
print(f"Versions: {versions_content}")

# Set up headers
print("Setting up headers...")
headers = {
    "publisher-key": auth.get('key', ''),
    "publisher-id": auth.get('id', '')
}
print(f"Headers set: {headers}")

# Upsert Master Version
master_changelog_path = os.path.join(workspace, 'CHANGELOG.md')
print(f"Loading master changelog from: {master_changelog_path}")
with open(master_changelog_path, 'r', encoding='utf-8') as f:
    master_changelog = f.read()

print("Preparing master version data...")
master_version_data = {
    "changelog": master_changelog,
    "version_name": versions_content.get('version', '')
}

print("Master version data prepared.")

print("Attempting to upsert Master Version...")

try:
    response = requests.post(
        f"{url}/master-version",
        headers=headers,
        json=master_version_data,
        timeout=300
    )
    response.raise_for_status()
    master_version_id = response.text.strip()
    print(f"Master Version ID: {master_version_id}")
except requests.exceptions.RequestException as e:
    print(f"Error in Master Version POST request: {e}")
    raise

print("Master Version upserted successfully.")

# Upsert Component Version, Scripts, and Files
for service in services:
    print(f"Processing service: {service}")
    path = service.replace("-", "/")
    service_path = os.path.join(workspace, path)

    # Add specific pre-build steps here
    if service == "agent-service":
        config_path = os.path.join(service_path, 'config')
        os.chdir(config_path)
        const_go_path = os.path.join(config_path, 'const.go')
        with open(const_go_path, 'r') as f:
            const_go_content = f.read()
        const_go_content = const_go_content.replace(
            'const REPLACE_KEY string = ""',
            f'const REPLACE_KEY string = "{replace_key}"'
        )
        with open(const_go_path, 'w') as f:
            f.write(const_go_content)

    os.chdir(service_path)

    # Upsert Component Version
    changelog_path = os.path.join(workspace, service, 'CHANGELOG.md')
    with open(changelog_path, 'r', encoding='utf-8') as f:
        changelog = f.read()

    readme_path = os.path.join(workspace, service, 'README.md')
    with open(readme_path, 'r', encoding='utf-8') as f:
        readme = f.read()

    component_version_data = {
        "changelog": changelog,
        "description": readme,
        "editions": ["Community", "Enterprise"],
        "master_version_id": master_version_id,
        "name": service,
        "version_name": versions_content.get(service, '')
    }

    try:
        response = requests.post(
            f"{url}/component-version",
            headers=headers,
            json=component_version_data,
            timeout=300
        )
        response.raise_for_status()
        component_version_id = response.text.strip()
        print(f"Component Version ID: {component_version_id}")
    except requests.exceptions.RequestException as e:
        print(f"Error in Component Version POST request: {e}")
        raise

    # Upsert Files and dependencies
    files_path = os.path.join(service_path, 'files.json')
    with open(files_path, 'r', encoding='utf-8') as f:
        files_content = json.load(f)

    for file in files_content:
        file_name = file['name']
        if file_name.endswith(('.zip', '.yaml', '.yml', '.json')):
            file_path = os.path.join(service_path, 'dependencies', file_name)
        else:
            # Build and sign the file if it's not a dependency
            os.environ['GOOS'] = file['os']
            os.environ['GOARCH'] = file['arch']
            print(f"Building {file_name} for {file['os']} {file['arch']}...")

            # Run 'go build' command
            build_command = ['go', 'build', '-o', file_name, '-v', '.']
            subprocess.run(build_command, check=True)

            if file['os'] == 'windows':
                print(f"Signing {file_name}...")
                # Run 'signtool' command
                signtool_command = [
                    'signtool',
                    'sign',
                    '/fd', 'SHA256',
                    '/tr', 'http://timestamp.digicert.com',
                    '/td', 'SHA256',
                    '/f', sign_cert,
                    '/csp', 'eToken Base Cryptographic Provider',
                    '/k', f"[{{{sign_key}}}]={sign_container}",
                    file_name
                ]
                subprocess.run(signtool_command, check=True)

            file_path = os.path.join(service_path, file_name)

        # Prepare file data
        file_data = {
            "version_id": component_version_id,
            "name": file_name,
            "is_binary": file['is_binary'],
            "destination_path": file['destination_path'],
            "os": file['os'],
            "arch": file['arch'],
            "replace_previous": file['replace_previous']
        }

        # Prepare multipart form data
        print(f"Uploading {file_name}...")
        files = {
            'data': (None, json.dumps(file_data), 'application/json'),
            'file': (file_name, open(file_path, 'rb'), 'application/octet-stream')
        }

        try:
            response = requests.post(
                f"{url}/upload-file",
                headers=headers,
                files=files,
                timeout=300
            )
            response.raise_for_status()
            response_content = response.text
            print(f"Upload Response for {file_name}:")
            print(response_content)
        except requests.exceptions.RequestException as e:
            print(f"Error in file upload for {file_name}: {e}")
            raise
        finally:
            # Close the file handle
            files['file'][1].close()

# Return to workspace directory
os.chdir(workspace)
# Remove all files and directories in the workspace
print("Cleaning up workspace...")
for filename in os.listdir('.'):
    file_path = os.path.join('.', filename)
    try:
        if os.path.isfile(file_path) or os.path.islink(file_path):
            os.unlink(file_path)
        elif os.path.isdir(file_path):
            shutil.rmtree(file_path)
    except Exception as e:
        print(f'Failed to delete {file_path}. Reason: {e}')
