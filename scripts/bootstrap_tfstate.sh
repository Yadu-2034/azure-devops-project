#!/usr/bin/env bash
# OPTIONAL: creates an Azure Storage account to hold Terraform remote state.
# Run once after `az login`, then uncomment the backend block in terraform/providers.tf.
set -euo pipefail

LOCATION="${1:-centralindia}"
RG="tfstate-rg"
SA="tfstate$RANDOM$RANDOM"   # storage account names must be globally unique
CONTAINER="tfstate"

az group create --name "$RG" --location "$LOCATION" >/dev/null
az storage account create --name "$SA" --resource-group "$RG" --location "$LOCATION" \
  --sku Standard_LRS --encryption-services blob >/dev/null
az storage container create --name "$CONTAINER" --account-name "$SA" --auth-mode login >/dev/null

echo
echo "Remote state backend ready. Put this in terraform/providers.tf:"
echo
echo '  backend "azurerm" {'
echo "    resource_group_name  = \"$RG\""
echo "    storage_account_name = \"$SA\""
echo "    container_name       = \"$CONTAINER\""
echo '    key                  = "webapp-cicd.tfstate"'
echo '  }'
