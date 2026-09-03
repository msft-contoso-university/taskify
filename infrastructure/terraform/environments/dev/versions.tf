# =============================================================================
# Terraform & Provider Versions — Dev Environment
# =============================================================================
# This is scaffolding only: it pins the Terraform and AzureRM provider
# versions so that real resource authoring (done later via the agentic
# workflow) starts from a consistent, known-good baseline. No resources are
# defined here yet.
# =============================================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }

  # Remote state backend is intentionally left unconfigured in this scaffold.
  # Configure an azurerm backend (storage account + container) before any
  # real `terraform init` is run against Azure, e.g.:
  #
  # backend "azurerm" {
  #   resource_group_name  = "rg-taskify-tfstate"
  #   storage_account_name = "sttaskifytfstatedev"
  #   container_name       = "tfstate"
  #   key                  = "taskify-dev.tfstate"
  # }
}
