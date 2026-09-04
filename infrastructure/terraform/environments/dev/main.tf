# =============================================================================
# Dev Environment — Root Module
# =============================================================================
# Composes the reusable Terraform modules into the complete dev environment.
# =============================================================================

locals {
  deployer_key_vault_secret_officer_object_ids = var.grant_deployer_key_vault_secret_officer ? toset([data.azurerm_client_config.current.object_id]) : toset([])

  key_vault_secret_officer_object_ids = setunion(
    var.key_vault_secret_officer_object_ids,
    local.deployer_key_vault_secret_officer_object_ids
  )

  tags = merge(
    {
      managed-by = "terraform"
      stack      = "taskify"
    },
    var.tags
  )
}

data "azurerm_client_config" "current" {}

module "foundation" {
  source = "../../modules/foundation"

  environment = var.environment
  location    = var.location
  name_prefix = var.name_prefix
  tags        = local.tags

  resource_group_name                               = var.resource_group_name
  key_vault_name                                    = var.key_vault_name
  key_vault_public_network_access_enabled           = var.key_vault_public_network_access_enabled
  key_vault_network_acls_default_action             = var.key_vault_network_acls_default_action
  key_vault_network_acls_bypass                     = var.key_vault_network_acls_bypass
  key_vault_network_acls_ip_rules                   = var.key_vault_network_acls_ip_rules
  key_vault_network_acls_virtual_network_subnet_ids = var.key_vault_network_acls_virtual_network_subnet_ids
  key_vault_purge_protection_enabled                = var.key_vault_purge_protection_enabled
  key_vault_secret_officer_object_ids               = local.key_vault_secret_officer_object_ids
  vnet_address_space                                = var.vnet_address_space
  container_apps_subnet_address_prefixes            = var.container_apps_subnet_address_prefixes
  postgres_subnet_address_prefixes                  = var.postgres_subnet_address_prefixes
  private_endpoints_subnet_address_prefixes         = var.private_endpoints_subnet_address_prefixes
}

module "data" {
  source = "../../modules/data"

  environment                  = var.environment
  location                     = var.location
  name_prefix                  = var.name_prefix
  tags                         = local.tags
  resource_group_name          = module.foundation.resource_group_name
  postgres_delegated_subnet_id = module.foundation.subnet_ids.postgres
  virtual_network_id           = module.foundation.virtual_network_id
  key_vault_id                 = module.foundation.key_vault_id

  server_name                   = var.postgres_server_name
  private_dns_zone_name         = var.postgres_private_dns_zone_name
  postgres_version              = var.postgres_version
  sku_name                      = var.postgres_sku_name
  storage_mb                    = var.postgres_storage_mb
  backup_retention_days         = var.postgres_backup_retention_days
  administrator_login           = var.postgres_administrator_login
  database_name                 = var.postgres_database_name
  connection_host_secret_name   = var.postgres_connection_host_secret_name
  admin_username_secret_name    = var.postgres_admin_username_secret_name
  admin_password_secret_name    = var.postgres_admin_password_secret_name
  database_name_secret_name     = var.postgres_database_name_secret_name
  connection_string_secret_name = var.postgres_connection_string_secret_name

  depends_on = [module.foundation]
}

module "containers" {
  source = "../../modules/containers"

  environment              = var.environment
  location                 = var.location
  name_prefix              = var.name_prefix
  tags                     = local.tags
  resource_group_name      = module.foundation.resource_group_name
  container_apps_subnet_id = module.foundation.subnet_ids.container_apps

  acr_name                                                 = var.acr_name
  acr_sku                                                  = var.acr_sku
  container_app_environment_name                           = var.container_app_environment_name
  container_app_environment_internal_load_balancer_enabled = var.container_app_environment_internal_load_balancer_enabled
  log_analytics_workspace_name                             = var.log_analytics_workspace_name

  depends_on = [module.foundation]
}

module "application" {
  source = "../../modules/application"

  environment                  = var.environment
  location                     = var.location
  name_prefix                  = var.name_prefix
  tags                         = local.tags
  resource_group_name          = module.foundation.resource_group_name
  container_app_environment_id = module.containers.container_app_environment_id
  acr_id                       = module.containers.acr_id
  acr_login_server             = module.containers.acr_login_server
  key_vault_id                 = module.foundation.key_vault_id
  key_vault_uri                = module.foundation.key_vault_uri

  postgres_connection_host_secret_name   = module.data.key_vault_secret_names.host
  postgres_admin_username_secret_name    = module.data.key_vault_secret_names.admin_username
  postgres_admin_password_secret_name    = module.data.key_vault_secret_names.admin_password
  postgres_connection_string_secret_name = module.data.key_vault_secret_names.connection_string
  postgres_connection_string_secret_id   = module.data.key_vault_secret_ids.connection_string
  postgres_database_name                 = module.data.database_name

  api_image_repository = var.api_image_repository
  api_image_tag        = var.api_image_tag
  web_image_repository = var.web_image_repository
  web_image_tag        = var.web_image_tag

  api_container_app_name = var.api_container_app_name
  web_container_app_name = var.web_container_app_name
  api_target_port        = var.api_target_port
  web_target_port        = var.web_target_port
  api_cpu                = var.api_cpu
  api_memory             = var.api_memory
  web_cpu                = var.web_cpu
  web_memory             = var.web_memory
  min_replicas           = var.min_replicas
  max_replicas           = var.max_replicas

  depends_on = [
    module.data,
    module.containers
  ]
}
