variable "environment" {
  description = "Deployment environment name used in resource naming and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.environment))
    error_message = "environment must be 2-12 lowercase letters, numbers, or hyphens."
  }
}

variable "location" {
  description = "Azure region for all foundation resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for foundation resource names."
  type        = string
  default     = "taskify"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,18}$", var.name_prefix))
    error_message = "name_prefix must be 2-18 lowercase letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Optional resource group name. Defaults to <name_prefix>-<environment>-rg."
  type        = string
  default     = null
}

variable "key_vault_name" {
  description = "Optional Key Vault name. Defaults to <name_prefix><environment>kv with hyphens removed."
  type        = string
  default     = null

  validation {
    condition = (
      var.key_vault_name == null
      || (
        can(regex("^[a-z][a-z0-9-]{1,22}[a-z0-9]$", var.key_vault_name))
        && !can(regex("--", var.key_vault_name))
      )
    )
    error_message = "key_vault_name must be 3-24 characters, start with a letter, end with a letter or number, and contain only lowercase letters, numbers, and single hyphens."
  }
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.42.0.0/16"]
}

variable "container_apps_subnet_address_prefixes" {
  description = "Address prefixes for the delegated Container Apps Environment subnet."
  type        = list(string)
  default     = ["10.42.0.0/23"]
}

variable "postgres_subnet_address_prefixes" {
  description = "Address prefixes for the delegated PostgreSQL Flexible Server subnet."
  type        = list(string)
  default     = ["10.42.2.0/24"]
}

variable "private_endpoints_subnet_address_prefixes" {
  description = "Address prefixes for the subnet reserved for future private endpoints."
  type        = list(string)
  default     = ["10.42.3.0/24"]
}

variable "key_vault_sku_name" {
  description = "SKU for the shared Key Vault."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "key_vault_sku_name must be either standard or premium."
  }
}

variable "key_vault_purge_protection_enabled" {
  description = "Whether purge protection is enabled for the shared Key Vault."
  type        = bool
  default     = false
}

variable "key_vault_public_network_access_enabled" {
  description = "Whether public network access is enabled for the shared Key Vault."
  type        = bool
  default     = false
}

variable "key_vault_network_acls_default_action" {
  description = "Default firewall action for Key Vault network ACLs."
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_network_acls_default_action)
    error_message = "key_vault_network_acls_default_action must be either Allow or Deny."
  }
}

variable "key_vault_network_acls_bypass" {
  description = "Traffic bypass setting for Key Vault network ACLs."
  type        = string
  default     = "None"

  validation {
    condition     = contains(["AzureServices", "None"], var.key_vault_network_acls_bypass)
    error_message = "key_vault_network_acls_bypass must be either AzureServices or None."
  }
}

variable "key_vault_network_acls_ip_rules" {
  description = "Public IP addresses or CIDR ranges allowed through the Key Vault firewall."
  type        = list(string)
  default     = []
}

variable "key_vault_network_acls_virtual_network_subnet_ids" {
  description = "Subnet IDs allowed through the Key Vault firewall."
  type        = list(string)
  default     = []
}

variable "key_vault_secret_officer_object_ids" {
  description = "Microsoft Entra object IDs that should receive Key Vault Secrets Officer on this vault."
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all foundation resources."
  type        = map(string)
  default     = {}
}
