# =============================================================================
# Provider Configuration — Dev Environment
# =============================================================================
# Scaffolding only. Subscription/tenant are sourced from variables (which
# default to this project's Azure target, documented in
# infrastructure/README.md) so no IDs are hardcoded as literals in provider
# blocks. Authentication is expected via environment variables
# (ARM_CLIENT_ID / ARM_CLIENT_SECRET / ARM_TENANT_ID / ARM_SUBSCRIPTION_ID)
# or OIDC federated credentials in CI — never via credentials committed here.
# =============================================================================

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  features {}
}

variable "subscription_id" {
  description = "Azure subscription ID to deploy into."
  type        = string
  default     = "c8c3c87b-d7b9-47fa-907a-0af1ea1cedab"
}

variable "tenant_id" {
  description = "Azure AD tenant ID."
  type        = string
  default     = "d11cdc76-c6f2-4368-a98f-498e78a7e011"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "eastus"
}
