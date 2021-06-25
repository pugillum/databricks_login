#!/bin/bash

set -e

export SUBSCRIPTION=$1
export RESOURCE_GROUP=$2
export DATABRICKS=$3


if [[ -z "$SUBSCRIPTION" ]]; then
  echo "Subscription is not configured"
  exit 1
fi
if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "Resource group is not configured"
  exit 1
fi
if [[ -z "$DATABRICKS" ]]; then
  echo "Databricks is not specified"
  exit 1
fi

# Get access tokens using the Azure CLI
export MANAGEMENT_ACCESS_TOKEN=$(az account get-access-token --resource https://management.core.windows.net/ | jq --raw-output '.accessToken')
export ACCESS_TOKEN=$(az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d | jq --raw-output '.accessToken')

# Fetch the Databricks organisation and host
DATABRICKS_ORG_ID=$(az rest -m get -u https://management.azure.com/subscriptions/${SUBSCRIPTION}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Databricks/workspaces/${DATABRICKS}?api-version=2018-04-01 --query properties.workspaceId -o tsv)
DATABRICKS_HOST="https://$(az rest -m get -u https://management.azure.com/subscriptions/${SUBSCRIPTION}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Databricks/workspaces/${DATABRICKS}?api-version=2018-04-01 --query properties.workspaceUrl -o tsv)"

# Fetch the admin token
OUTPUT=$(curl -s \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "X-Databricks-Azure-SP-Management-Token: ${MANAGEMENT_ACCESS_TOKEN}" \
  -H "X-Databricks-Azure-Workspace-Resource-Id: /subscriptions/${SUBSCRIPTION}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Databricks/workspaces/${DATABRICKS}" "${DATABRICKS_HOST}/api/2.0/token/create" \
  -d '{"lifetime_seconds": 21600, "comment": "Token for job deployments"}' \
  ${DATABRICKS_HOST}/api/2.0/token/create)

# Set the token
DATABRICKS_TOKEN=$(echo ${OUTPUT} | jq -r .token_value | head -n 1)
printf "[DEFAULT]\nhost = ${DATABRICKS_HOST}\ntoken = ${DATABRICKS_TOKEN}" >~/.databrickscfg
cat ~/.databrickscfg
