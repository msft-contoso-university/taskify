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

  # Partial backend configuration supplied via -backend-config at init time;
  # see environments/dev/versions.tf for the full explanation.
  backend "azurerm" {
    use_azuread_auth = true
    use_oidc         = true
  }
}
