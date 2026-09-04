variable "environment" {
  description = "Deployment environment name used in resource naming and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.environment))
    error_message = "environment must be 2-12 lowercase letters, numbers, or hyphens."
  }
}

variable "location" {
  description = "Azure region for all application resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name from the foundation module."
  type        = string
}

variable "container_app_environment_id" {
  description = "Container Apps Environment ID from the containers module."
  type        = string
}

variable "acr_id" {
  description = "Azure Container Registry resource ID from the containers module."
  type        = string
}

variable "acr_login_server" {
  description = "Azure Container Registry login server from the containers module."
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault resource ID from the foundation module, used to scope API secret-read RBAC to required PostgreSQL secrets."
  type        = string
}

variable "key_vault_uri" {
  description = "Key Vault URI from the foundation module, passed to the API for managed-identity secret lookup."
  type        = string
}

variable "postgres_connection_host_secret_name" {
  description = "Key Vault secret name for the PostgreSQL host from the data module."
  type        = string
}

variable "postgres_admin_username_secret_name" {
  description = "Key Vault secret name for the PostgreSQL admin username from the data module."
  type        = string
}

variable "postgres_admin_password_secret_name" {
  description = "Key Vault secret name for the PostgreSQL admin password from the data module."
  type        = string
}

variable "postgres_connection_string_secret_name" {
  description = "Key Vault secret name for the PostgreSQL connection string from the data module."
  type        = string
}

variable "postgres_database_name" {
  description = "PostgreSQL application database name from the data module."
  type        = string
  default     = "taskify"
}

variable "postgres_connection_string_secret_id" {
  description = "Key Vault secret ID for the PostgreSQL connection string from the data module."
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

variable "api_image_repository" {
  description = "ACR repository name for the API image. Image build and push automation is out of scope for this module."
  type        = string
  default     = "taskify-api"
}

variable "api_image_tag" {
  description = "API image tag already pushed to ACR. Use a placeholder tag only if that image exists in the registry."
  type        = string
  default     = "dev"
}

variable "web_image_repository" {
  description = "ACR repository name for the web image. Image build and push automation is out of scope for this module."
  type        = string
  default     = "taskify-web"
}

variable "web_image_tag" {
  description = "Web image tag already pushed to ACR. Use a placeholder tag only if that image exists in the registry."
  type        = string
  default     = "dev"
}

variable "api_container_app_name" {
  description = "Optional API Container App name override. Defaults to <name_prefix>-<environment>-api."
  type        = string
  default     = null
}

variable "web_container_app_name" {
  description = "Optional web Container App name override. Defaults to <name_prefix>-<environment>-web."
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

variable "tags" {
  description = "Tags applied to all application resources."
  type        = map(string)
  default     = {}
}
