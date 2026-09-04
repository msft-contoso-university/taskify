output "postgresql_server_id" {
  description = "ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "postgresql_server_name" {
  description = "Name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "postgresql_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_name" {
  description = "Name of the application database created on the server."
  value       = azurerm_postgresql_flexible_server_database.app.name
}

output "private_dns_zone_id" {
  description = "ID of the PostgreSQL private DNS zone. Null when use_private_networking is false."
  value       = var.use_private_networking ? azurerm_private_dns_zone.postgres[0].id : null
}

output "key_vault_secret_names" {
  description = "Key Vault secret names that contain PostgreSQL connection data for downstream modules."
  value = {
    host              = azurerm_key_vault_secret.postgres_connection_host.name
    admin_username    = azurerm_key_vault_secret.postgres_admin_username.name
    admin_password    = azurerm_key_vault_secret.postgres_admin_password.name
    database_name     = azurerm_key_vault_secret.postgres_database_name.name
    connection_string = azurerm_key_vault_secret.postgres_connection_string.name
  }
}

output "key_vault_secret_ids" {
  description = "Key Vault secret IDs for PostgreSQL connection data."
  value = {
    host              = azurerm_key_vault_secret.postgres_connection_host.id
    admin_username    = azurerm_key_vault_secret.postgres_admin_username.id
    admin_password    = azurerm_key_vault_secret.postgres_admin_password.id
    database_name     = azurerm_key_vault_secret.postgres_database_name.id
    connection_string = azurerm_key_vault_secret.postgres_connection_string.id
  }
}
