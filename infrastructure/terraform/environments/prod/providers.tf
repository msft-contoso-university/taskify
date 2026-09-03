# =============================================================================
# Provider Configuration — Prod Environment
# =============================================================================
# Scaffolding only — see environments/dev/providers.tf for notes.
# =============================================================================

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  features {}
}

variable "subscription_id" {
  description = "Azure subscription ID to deploy into."
  type        = string
  default     = "8fcc5e8e-6540-4288-89e7-849e94290205"
}

variable "tenant_id" {
  description = "Azure AD tenant ID."
  type        = string
  default     = "16b3c013-d300-468d-ac64-7eda0820b6d3"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "eastus"
}
