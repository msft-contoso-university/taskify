# =============================================================================
# Terraform & Provider Versions — Dev Environment
# =============================================================================
# Pins the Terraform and provider versions for the composed dev environment.
# =============================================================================

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }

  # Partial backend configuration: resource_group_name, storage_account_name,
  # container_name, and key are supplied at init time via `-backend-config`
  # flags (see .github/workflows/terraform-cd.yml and, for local use,
  # `terraform init -backend-config=...` or a local backend.hcl you do not
  # commit). This keeps environment-specific storage account names out of
  # source control while still using a real remote state backend with
  # locking once the backend storage account exists.
  backend "azurerm" {
    use_azuread_auth = true
    use_oidc         = true
  }
}
