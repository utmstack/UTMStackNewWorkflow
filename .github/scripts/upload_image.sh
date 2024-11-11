#!/bin/bash

if [ -z "$1" ]; then
  echo "No services provided to send."
  exit 1
fi

image_services=$1
echo "Sending the following image services to the server: $image_services"

services_array=$(echo "$image_services" | jq -c '.[]')

workspace="$GITHUB_WORKSPACE"
url="$CM_API"

echo "Services: ${services_array[*]}"
echo "Workspace: $workspace"
echo "URL: $url"

auth_id=$(echo "$CM_PUB_AUTH" | jq -r '.id')
auth_key=$(echo "$CM_PUB_AUTH" | jq -r '.key')

versions_json_path="$workspace/versions.json"
echo "Loading versions.json from: $versions_json_path"
versions_content=$(cat "$versions_json_path")
echo "Versions: $versions_content"

master_changelog_path="$workspace/CHANGELOG.md"
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

for service in "${services[@]}"; do
    echo "Processing service: $service"
    path="${service//-//}"
    service_path="$workspace/$path"

    changelog=$(cat "$workspace/$service/CHANGELOG.md")
    readme=$(cat "$workspace/$service/README.md")

    component_version_data=$(jq -n \
        --arg changelog "$changelog" \
        --arg description "$readme" \
        --arg master_version_id "$master_version_id" \
        --arg name "$service" \
        --arg version_name "$(echo "$versions_content" | jq -r --arg s "$service" '.[$s]')" \
        '{changelog: $changelog, description: $description, editions: ["Community", "Enterprise"], master_version_id: $master_version_id, name: $name, version_name: $version_name}')

    component_version_response=$(curl -s -X POST "$url/component-version" \
        -H "publisher-key: $auth_key" \
        -H "publisher-id: $auth_id" \
        -H "Content-Type: application/json" \
        -d "$component_version_data")

    component_version_id="$component_version_response"
    echo "Component Version ID: $component_version_id"
done
