# =============================================================================
# Provider Configuration — Dev Environment
# =============================================================================
# Subscription/tenant are sourced from variables (which default to this
# project's Azure target, documented in infrastructure/README.md) so no IDs are
# hardcoded as literals in provider blocks. Authentication is expected via OIDC
# federated credentials in CI or standard ARM_* environment variables locally —
# never via credentials committed here.
# =============================================================================

provider "azurerm" {
  subscription_id = trimspace(var.subscription_id)
  tenant_id       = trimspace(var.tenant_id)

  features {}
}
