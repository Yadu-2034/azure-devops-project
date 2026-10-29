terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }

  # --- Remote state (optional, for extra marks) -------------------------------
  # Run scripts/bootstrap_tfstate.sh once, then uncomment this block and run
  # `terraform init -migrate-state`. State is then stored safely in Azure Storage.
  #
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "<value printed by bootstrap_tfstate.sh>"
  #   container_name       = "tfstate"
  #   key                  = "webapp-cicd.tfstate"
  # }
}

provider "azurerm" {
  features {}
}
