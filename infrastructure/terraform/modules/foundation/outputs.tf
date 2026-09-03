output "resource_group_id" {
  description = "ID of the application resource group."
  value       = azurerm_resource_group.this.id
}

output "resource_group_name" {
  description = "Name of the application resource group."
  value       = azurerm_resource_group.this.name
}

output "virtual_network_id" {
  description = "ID of the shared virtual network."
  value       = azurerm_virtual_network.this.id
}

output "virtual_network_name" {
  description = "Name of the shared virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Subnet IDs keyed by consumer purpose."
  value = {
    container_apps    = azurerm_subnet.container_apps.id
    postgres          = azurerm_subnet.postgres.id
    private_endpoints = azurerm_subnet.private_endpoints.id
  }
}

output "subnet_names" {
  description = "Subnet names keyed by consumer purpose."
  value = {
    container_apps    = azurerm_subnet.container_apps.name
    postgres          = azurerm_subnet.postgres.name
    private_endpoints = azurerm_subnet.private_endpoints.name
  }
}

output "key_vault_id" {
  description = "ID of the shared Key Vault."
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "Name of the shared Key Vault."
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "URI of the shared Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "key_vault_secret_officer_role_assignment_ids" {
  description = "Role assignment IDs for optional Key Vault Secrets Officer grants."
  value       = { for object_id, assignment in azurerm_role_assignment.key_vault_secret_officer : object_id => assignment.id }
}
