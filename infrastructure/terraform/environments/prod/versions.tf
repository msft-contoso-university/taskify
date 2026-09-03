# =============================================================================
# Terraform & Provider Versions — Prod Environment
# =============================================================================
# Scaffolding only — see environments/dev/versions.tf for notes. Prod uses
# its own state backend/key so dev and prod never share state.
# =============================================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }

  # backend "azurerm" {
  #   resource_group_name  = "rg-taskify-tfstate"
  #   storage_account_name = "sttaskifytfstateprod"
  #   container_name       = "tfstate"
  #   key                  = "taskify-prod.tfstate"
  # }
}
