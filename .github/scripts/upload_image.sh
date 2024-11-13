#!/bin/bash

if [ -z "$1" ]; then
  echo "No services provided to send."
  exit 1
fi

image_services=$1
echo "Sending the following image services to the server: $image_services"

if ! echo "$image_services" | jq empty >/dev/null 2>&1; then
    echo "Error: Provided image_services is not valid JSON."
    exit 1
fi

services_array=$(echo "$image_services" | jq -c '.[]')

workspace="$GITHUB_WORKSPACE"
url="$CM_API"

echo "Services: ${services_array[*]}"
echo "Workspace: $workspace"
echo "URL: $url"

auth_id=$(echo "$CM_PUB_AUTH" | jq -r '.id')
auth_key=$(echo "$CM_PUB_AUTH" | jq -r '.key')

versions_json_path="$workspace/versions.json"
if [ ! -f "$versions_json_path" ]; then
    echo "Error: versions.json not found at $versions_json_path"
    exit 1
fi

versions_content=$(cat "$versions_json_path")
echo "Versions: $versions_content"

master_changelog_path="$workspace/CHANGELOG.md"
if [ ! -f "$master_changelog_path" ]; then
    echo "Error: CHANGELOG.md not found at $master_changelog_path"
    exit 1
fi
master_changelog=$(cat "$master_changelog_path")

master_version_data=$(jq -n \
    --arg changelog "$master_changelog" \
    --arg version_name "$(echo "$versions_content" | jq -r '.version')" \
    '{changelog: $changelog, version_name: $version_name}')

echo "Sending main version..."
master_version_response=$(curl -s -X POST "$url/master-version" \
    -H "publisher-key: $auth_key" \
    -H "publisher-id: $auth_id" \
    -H "Content-Type: application/json" \
    -d "$master_version_data")

master_version_id="$master_version_response"
echo "Master Version ID: $master_version_id"

echo "$services_array" | while IFS= read -r service; do
    name=$(echo "$service" | jq -r '.name')
    version=$(echo "$service" | jq -r '.version')

    echo "Processing service: $name with version: $version"
    path="${name//-//}"
    service_path="$workspace/$path"

    changelog_path="$workspace/$path/CHANGELOG.md"
    readme_path="$workspace/$path/README.md"

    if [ ! -f "$changelog_path" ] || [ ! -f "$readme_path" ]; then
        echo "Error: Missing CHANGELOG.md or README.md for service $name"
        exit 1
    fi

    changelog=$(cat "$changelog_path")
    readme=$(cat "$readme_path")

    component_version_data=$(jq -n \
        --arg changelog "$changelog" \
        --arg description "$readme" \
        --arg master_version_id "$master_version_id" \
        --arg name "$name" \
        --arg version_name "$(echo "$versions_content" | jq -r --arg s "$name" '.[$s]')" \
        '{changelog: $changelog, description: $description, editions: ["Community", "Enterprise"], master_version_id: $master_version_id, name: $name, version_name: $version_name}')

    component_version_response=$(curl -s -X POST "$url/component-version" \
        -H "publisher-key: $auth_key" \
        -H "publisher-id: $auth_id" \
        -H "Content-Type: application/json" \
        -d "$component_version_data")

    component_version_id="$component_version_response"
    echo "Component Version ID: $component_version_id"
done
