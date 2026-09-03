locals {
  base_name           = "${var.name_prefix}-${var.environment}"
  resource_group_name = coalesce(var.resource_group_name, "${local.base_name}-rg")
  key_vault_name      = coalesce(var.key_vault_name, replace("${local.base_name}-kv", "-", ""))

  tags = merge(
    {
      application = var.name_prefix
      environment = var.environment
    },
    var.tags
  )
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${local.base_name}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.vnet_address_space
  tags                = local.tags
}

resource "azurerm_subnet" "container_apps" {
  name                 = "${local.base_name}-cae-snet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.container_apps_subnet_address_prefixes

  delegation {
    name = "container-apps-environment"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "postgres" {
  name                 = "${local.base_name}-postgres-snet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.postgres_subnet_address_prefixes

  delegation {
    name = "postgres-flexible-server"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                              = "${local.base_name}-private-endpoints-snet"
  resource_group_name               = azurerm_resource_group.this.name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = var.private_endpoints_subnet_address_prefixes
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_key_vault" "this" {
  name                          = local.key_vault_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.key_vault_sku_name
  enable_rbac_authorization     = true
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  soft_delete_retention_days    = 7
  public_network_access_enabled = var.key_vault_public_network_access_enabled
  tags                          = local.tags

  network_acls {
    bypass         = "None"
    default_action = "Deny"
  }

  lifecycle {
    precondition {
      condition     = var.key_vault_name != null || (length(local.key_vault_name) <= 24 && can(regex("^[a-z][a-z0-9]{2,23}$", local.key_vault_name)))
      error_message = "The computed Key Vault name must be 3-24 characters, start with a letter, and contain only lowercase letters and numbers. Set key_vault_name to a valid unique name."
    }
}

resource "azurerm_role_assignment" "key_vault_secret_officer" {
  for_each = var.key_vault_secret_officer_object_ids

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.value
}
