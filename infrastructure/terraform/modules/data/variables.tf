variable "environment" {
  description = "Deployment environment name used in resource naming and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.environment))
    error_message = "environment must be 2-12 lowercase letters, numbers, or hyphens."
  }
}

variable "location" {
  description = "Azure region for data resources. May differ from other resources' region since PostgreSQL Flexible Server does not require VNet delegation when running with public network access (demo/dev only)."
  type        = string
}

variable "use_private_networking" {
  description = "Whether to attach PostgreSQL to the delegated VNet subnet with a private DNS zone (true) or expose it via public network access gated by firewall rules (false). Use false when postgres_location differs from the VNet's region, since delegated subnets must be in the same region as the server."
  type        = bool
  default     = true
}

variable "public_access_allow_all_azure_ips" {
  description = "When use_private_networking is false, whether to allow all Azure-internal IPs (0.0.0.0 firewall rule) so Container Apps in a different region/VNet can reach the server. Demo/dev convenience only — do not use for production."
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "Resource group name where PostgreSQL and private DNS resources are created."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for resource naming."
  type        = string
  default     = "taskify"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,18}$", var.name_prefix))
    error_message = "name_prefix must be 2-18 lowercase letters, numbers, or hyphens."
  }
}

variable "server_name" {
  description = "Optional PostgreSQL Flexible Server name override."
  type        = string
  default     = null

  validation {
    condition = (
      var.server_name == null
      || can(regex("^[a-z][a-z0-9-]{1,61}[a-z0-9]$", var.server_name))
    )
    error_message = "server_name must be 3-63 characters, start with a letter, end with a letter/number, and contain only lowercase letters, numbers, or hyphens."
  }
}

variable "postgres_version" {
  description = "PostgreSQL major version for Azure Database for PostgreSQL Flexible Server."
  type        = string
  default     = "16"

  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16"], var.postgres_version)
    error_message = "postgres_version must be one of: 11, 12, 13, 14, 15, 16."
  }
}

variable "sku_name" {
  description = "Compute SKU for PostgreSQL Flexible Server. Burstable SKUs are recommended for dev/demo."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Provisioned storage size in megabytes for PostgreSQL Flexible Server."
  type        = number
  default     = 32768

  validation {
    condition     = var.storage_mb >= 32768
    error_message = "storage_mb must be at least 32768 MB for Flexible Server."
  }
}

variable "backup_retention_days" {
  description = "Backup retention in days for PostgreSQL Flexible Server."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35."
  }
}

variable "administrator_login" {
  description = "Administrator username for PostgreSQL Flexible Server."
  type        = string
  default     = "taskifyadmin"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,62}$", var.administrator_login))
    error_message = "administrator_login must be 3-63 characters, start with a lowercase letter, and use lowercase letters/numbers only."
  }
}

variable "database_name" {
  description = "Application database name to create."
  type        = string
  default     = "taskify"

  validation {
    condition     = can(regex("^[a-z][a-z0-9_]{1,62}$", var.database_name))
    error_message = "database_name must be 2-63 characters, start with a lowercase letter, and use lowercase letters, numbers, or underscores."
  }
}

variable "postgres_delegated_subnet_id" {
  description = "ID of the delegated PostgreSQL subnet from the foundation module. Required only when use_private_networking is true."
  type        = string
  default     = null
}

variable "virtual_network_id" {
  description = "ID of the shared virtual network from the foundation module. Required only when use_private_networking is true."
  type        = string
  default     = null
}

variable "public_network_access_ip_rules" {
  description = "CIDR-free single IP addresses allowed through the PostgreSQL firewall when use_private_networking is false (e.g. the GitHub Actions runner IP at apply time)."
  type        = list(string)
  default     = []
}

variable "private_dns_zone_name" {
  description = "Optional private DNS zone name. Defaults to <name_prefix>-<environment>.postgres.database.azure.com."
  type        = string
  default     = null

  validation {
    condition = (
      var.private_dns_zone_name == null
      || can(regex("^[a-z0-9-]+\\.postgres\\.database\\.azure\\.com$", var.private_dns_zone_name))
    )
    error_message = "private_dns_zone_name must end with .postgres.database.azure.com and use lowercase letters, numbers, and hyphens."
  }
}

variable "key_vault_id" {
  description = "ID of the Key Vault where PostgreSQL secrets are stored."
  type        = string
}

variable "connection_host_secret_name" {
  description = "Key Vault secret name for PostgreSQL host/FQDN."
  type        = string
  default     = "postgresql-connection-host"
}

variable "admin_username_secret_name" {
  description = "Key Vault secret name for PostgreSQL admin username."
  type        = string
  default     = "postgresql-admin-username"
}

variable "admin_password_secret_name" {
  description = "Key Vault secret name for PostgreSQL admin password."
  type        = string
  default     = "postgresql-admin-password"
}

variable "database_name_secret_name" {
  description = "Key Vault secret name for PostgreSQL database name."
  type        = string
  default     = "postgresql-database-name"
}

variable "connection_string_secret_name" {
  description = "Key Vault secret name for the PostgreSQL connection string."
  type        = string
  default     = "postgresql-connection-string"
}

variable "tags" {
  description = "Tags applied to all data resources."
  type        = map(string)
  default     = {}
}
