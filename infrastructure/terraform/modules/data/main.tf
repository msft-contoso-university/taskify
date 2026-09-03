locals {
  base_name = "${var.name_prefix}-${var.environment}"

  postgres_server_name = coalesce(var.server_name, "${local.base_name}-psql")
  private_dns_zone_name = coalesce(
    var.private_dns_zone_name,
    "${local.base_name}.postgres.database.azure.com"
  )

  tags = merge(
    {
      application = var.name_prefix
      environment = var.environment
    },
    var.tags
  )
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = local.private_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${local.base_name}-postgres-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.virtual_network_id
  tags                  = local.tags
}

resource "random_password" "postgres_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                          = local.postgres_server_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  version                       = var.postgres_version
  delegated_subnet_id           = var.postgres_delegated_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false

  administrator_login    = var.administrator_login
  administrator_password = random_password.postgres_admin.result

  sku_name              = var.sku_name
  storage_mb            = var.storage_mb
  backup_retention_days = var.backup_retention_days

  tags = local.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_key_vault_secret" "postgres_connection_host" {
  name         = var.connection_host_secret_name
  value        = azurerm_postgresql_flexible_server.this.fqdn
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "postgres_admin_username" {
  name         = var.admin_username_secret_name
  value        = azurerm_postgresql_flexible_server.this.administrator_login
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = var.admin_password_secret_name
  value        = random_password.postgres_admin.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "postgres_database_name" {
  name         = var.database_name_secret_name
  value        = azurerm_postgresql_flexible_server_database.app.name
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "postgres_connection_string" {
  name = var.connection_string_secret_name
  value = format(
    "postgresql://%s:%s@%s:5432/%s?sslmode=require",
    azurerm_postgresql_flexible_server.this.administrator_login,
    urlencode(random_password.postgres_admin.result),
    azurerm_postgresql_flexible_server.this.fqdn,
    azurerm_postgresql_flexible_server_database.app.name
  )
  key_vault_id = var.key_vault_id
}
