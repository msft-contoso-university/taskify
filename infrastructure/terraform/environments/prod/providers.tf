# =============================================================================
# Provider Configuration — Prod Environment
# =============================================================================
# Scaffolding only — see environments/dev/providers.tf for notes.
# =============================================================================

provider "azurerm" {
  subscription_id = trimspace(var.subscription_id)
  tenant_id       = trimspace(var.tenant_id)

  features {}
}

variable "subscription_id" {
  description = "Azure subscription ID to deploy into."
  type        = string
  default     = "b6f10878-9f8a-4b3f-8bc5-3464cdd79c77"
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
