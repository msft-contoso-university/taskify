locals {
  base_name = "${var.name_prefix}-${var.environment}"

  acr_name = coalesce(var.acr_name, replace("${local.base_name}acr", "-", ""))

  container_app_environment_name = coalesce(var.container_app_environment_name, "${local.base_name}-cae")
  log_analytics_workspace_name   = coalesce(var.log_analytics_workspace_name, "${local.base_name}-law")

  tags = merge(
    {
      application = var.name_prefix
      environment = var.environment
    },
    var.tags
  )
}

resource "azurerm_container_registry" "this" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = local.tags

  lifecycle {
    precondition {
      condition     = can(regex("^[a-z0-9]{5,50}$", local.acr_name))
      error_message = "The computed ACR name must be 5-50 lowercase letters or numbers. Set acr_name to a valid globally unique name if needed."
    }
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_container_app_environment" "this" {
  name                         = local.container_app_environment_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  infrastructure_subnet_id     = var.container_apps_subnet_id
  internal_load_balancer_enabled = true
  log_analytics_workspace_id   = azurerm_log_analytics_workspace.this.id
  tags                         = local.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each = var.acr_pull_principal_ids

  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}
