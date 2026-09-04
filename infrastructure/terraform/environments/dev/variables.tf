variable "subscription_id" {
  description = "Azure subscription ID to deploy into."
  type        = string
  default     = "8fcc5e8e-6540-4288-89e7-849e94290205"
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

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.environment))
    error_message = "environment must be 2-12 lowercase letters, numbers, or hyphens."
  }
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "eastus"
}

variable "name_prefix" {
  description = "Prefix used for dev resource names."
  type        = string
  default     = "taskify"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,18}$", var.name_prefix))
    error_message = "name_prefix must be 2-18 lowercase letters, numbers, or hyphens."
  }
}

variable "tags" {
  description = "Additional tags applied to all dev resources."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Optional dev resource group name override."
  type        = string
  default     = null
}

variable "key_vault_name" {
  description = "Optional Key Vault name override for global uniqueness."
  type        = string
  default     = null
}

variable "key_vault_public_network_access_enabled" {
  description = "Whether public network access is enabled for the shared Key Vault. Keep false unless Terraform runs from an allowed private network path or scoped network ACLs are configured for secret creation."
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

variable "key_vault_purge_protection_enabled" {
  description = "Whether purge protection is enabled for the shared Key Vault."
  type        = bool
  default     = false
}

variable "key_vault_secret_officer_object_ids" {
  description = "Microsoft Entra object IDs that should receive Key Vault Secrets Officer on the shared vault."
  type        = set(string)
  default     = []
}

variable "grant_deployer_key_vault_secret_officer" {
  description = "Whether to grant Key Vault Secrets Officer to the current Terraform deployer identity so it can create generated PostgreSQL secrets."
  type        = bool
  default     = false
}

variable "vnet_address_space" {
  description = "Address space for the dev virtual network."
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

variable "postgres_server_name" {
  description = "Optional PostgreSQL Flexible Server name override."
  type        = string
  default     = null
}

variable "postgres_private_dns_zone_name" {
  description = "Optional PostgreSQL private DNS zone name override."
  type        = string
  default     = null
}

variable "postgres_version" {
  description = "PostgreSQL major version for Azure Database for PostgreSQL Flexible Server."
  type        = string
  default     = "16"
}

variable "postgres_sku_name" {
  description = "Compute SKU for PostgreSQL Flexible Server."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "Provisioned PostgreSQL storage size in megabytes."
  type        = number
  default     = 32768
}

variable "postgres_backup_retention_days" {
  description = "Backup retention in days for PostgreSQL Flexible Server."
  type        = number
  default     = 7
}

variable "postgres_administrator_login" {
  description = "Administrator username for PostgreSQL Flexible Server."
  type        = string
  default     = "taskifyadmin"
}

variable "postgres_database_name" {
  description = "Application database name to create."
  type        = string
  default     = "taskify"
}

variable "postgres_connection_host_secret_name" {
  description = "Key Vault secret name for the PostgreSQL host/FQDN."
  type        = string
  default     = "postgresql-connection-host"
}

variable "postgres_admin_username_secret_name" {
  description = "Key Vault secret name for the PostgreSQL admin username."
  type        = string
  default     = "postgresql-admin-username"
}

variable "postgres_admin_password_secret_name" {
  description = "Key Vault secret name for the generated PostgreSQL admin password."
  type        = string
  default     = "postgresql-admin-password"
}

variable "postgres_database_name_secret_name" {
  description = "Key Vault secret name for the PostgreSQL database name."
  type        = string
  default     = "postgresql-database-name"
}

variable "postgres_connection_string_secret_name" {
  description = "Key Vault secret name for the PostgreSQL connection string."
  type        = string
  default     = "postgresql-connection-string"
}

variable "acr_name" {
  description = "Optional ACR name override for global uniqueness."
  type        = string
  default     = null
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
  description = "Optional Container Apps Environment name override."
  type        = string
  default     = null
}

variable "container_app_environment_internal_load_balancer_enabled" {
  description = "Whether the Container Apps Environment uses an internal load balancer. Dev defaults to false so web_fqdn is publicly reachable, which removes internal-only isolation at the environment level."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_name" {
  description = "Optional Log Analytics workspace name override."
  type        = string
  default     = null
}

variable "api_image_repository" {
  description = "ACR repository name for the API image."
  type        = string
  default     = "taskify-api"
}

variable "api_image_tag" {
  description = "API image tag already pushed to ACR."
  type        = string
  default     = "dev"
}

variable "web_image_repository" {
  description = "ACR repository name for the web image."
  type        = string
  default     = "taskify-web"
}

variable "web_image_tag" {
  description = "Web image tag already pushed to ACR."
  type        = string
  default     = "dev"
}

variable "api_container_app_name" {
  description = "API Container App name. Defaults to api so the checked-in web image can proxy /api to http://api:3000."
  type        = string
  default     = "api"
}

variable "web_container_app_name" {
  description = "Optional web Container App name override."
  type        = string
  default     = null
}

variable "api_target_port" {
  description = "Port exposed by the API container."
  type        = number
  default     = 3000
}

variable "web_target_port" {
  description = "Port exposed by the web container."
  type        = number
  default     = 80
}

variable "api_cpu" {
  description = "CPU allocated to the API container."
  type        = number
  default     = 0.25
}

variable "api_memory" {
  description = "Memory allocated to the API container."
  type        = string
  default     = "0.5Gi"
}

variable "web_cpu" {
  description = "CPU allocated to the web container."
  type        = number
  default     = 0.25
}

variable "web_memory" {
  description = "Memory allocated to the web container."
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Minimum replica count for each dev Container App."
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum replica count for each dev Container App."
  type        = number
  default     = 1
}

# trigger apply: 2026-09-03T22:11:10.3103232-04:00
