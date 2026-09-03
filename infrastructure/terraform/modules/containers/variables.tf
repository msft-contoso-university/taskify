variable "environment" {
  description = "Deployment environment name used in resource naming and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.environment))
    error_message = "environment must be 2-12 lowercase letters, numbers, or hyphens."
  }
}

variable "location" {
  description = "Azure region for all container-platform resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name from the foundation module."
  type        = string
}

variable "container_apps_subnet_id" {
  description = "Delegated Container Apps subnet ID from the foundation module output subnet_ids.container_apps."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
  default     = "taskify"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,18}$", var.name_prefix))
    error_message = "name_prefix must be 2-18 lowercase letters, numbers, or hyphens."
  }
}

variable "acr_name" {
  description = "Optional ACR name override for global uniqueness. Defaults to <name_prefix><environment>acr with hyphens removed."
  type        = string
  default     = null

  validation {
    condition     = var.acr_name == null || can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "acr_name must be 5-50 lowercase letters or numbers."
  }
}

variable "acr_sku" {
  description = "ACR SKU for this environment."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard"], var.acr_sku)
    error_message = "acr_sku must be either Basic or Standard."
  }
}

variable "container_app_environment_name" {
  description = "Optional Container Apps Environment name override. Defaults to <name_prefix>-<environment>-cae."
  type        = string
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "Optional Log Analytics workspace name override. Defaults to <name_prefix>-<environment>-law."
  type        = string
  default     = null
}

variable "acr_pull_principal_ids" {
  description = "Microsoft Entra object IDs that should receive AcrPull on this registry."
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all container-platform resources."
  type        = map(string)
  default     = {}
}
