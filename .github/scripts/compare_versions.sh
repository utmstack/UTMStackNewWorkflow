#!/bin/bash

versions=$(cat "$GITHUB_WORKSPACE/versions.json")
main_version=$(echo "${versions}" | jq -r '.version')

auth_id=$(echo "$CM_PUB_AUTH" | jq -r '.id')
auth_key=$(echo "$CM_PUB_AUTH" | jq -r '.key')

script_services=("agent-service" "agent-installer" "plugins-alerts" "plugins-aws" "plugins-azure" "plugins-bitdefender" "plugins-config" "plugins-events" "plugins-gcp" "plugins-geolocation" "plugins-inputs" "plugins-o365" "plugins-sophos" "plugins-stats")
image_services=("agent-manager" "backend" "frontend" "user-auditor" "web-pdf")

api_url="$CM_API/component-versions?master-version=${main_version}"
api_versions=$(curl -s -H "publisher-key: $auth_key" -H "publisher-id: $auth_id" "${api_url}")

updated_script_services=()
updated_image_services=()

for service in $(echo "${versions}" | jq -r 'keys_unsorted[] | select(. != "version")'); do
    service_version=$(echo "${versions}" | jq -r --arg s "$service" '.[$s]')
    api_version=$(echo "${api_versions}" | jq -r --arg s "$service" '.[$s]')

    if [[ " ${script_services[@]} " =~ " ${service} " ]] && [ "${service_version}" != "${api_version}" ]; then
        updated_script_services+=("$service")
    fi
    if [[ " ${image_services[@]} " =~ " ${service} " ]] && [ "${service_version}" != "${api_version}" ]; then
        version="${service_version}"
        updated_image_services+=("{\"name\":\"$service\",\"version\":\"$version\"}")
    fi
done

script_services_output=$(IFS=,; echo "${updated_script_services[*]}")
image_services_output="[$(IFS=,; echo "${updated_image_services[*]}")]"

echo "script_services=${script_services_output}" >> $GITHUB_OUTPUT
echo "image_services=${image_services_json}" >> $GITHUB_OUTPUT
