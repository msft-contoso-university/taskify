output "api_container_app_id" {
  description = "ID of the API Container App."
  value       = azurerm_container_app.api.id
}

output "api_container_app_name" {
  description = "Name of the API Container App."
  value       = azurerm_container_app.api.name
}

output "api_fqdn" {
  description = "Internal ingress FQDN for the API Container App."
  value       = azurerm_container_app.api.ingress[0].fqdn
}

output "api_identity_principal_id" {
  description = "Principal ID of the API user-assigned managed identity."
  value       = azurerm_user_assigned_identity.api.principal_id
}

output "web_container_app_id" {
  description = "ID of the web Container App."
  value       = azurerm_container_app.web.id
}

output "web_container_app_name" {
  description = "Name of the web Container App."
  value       = azurerm_container_app.web.name
}

output "web_fqdn" {
  description = "Public ingress FQDN for the web Container App."
  value       = azurerm_container_app.web.latest_revision_fqdn
}

output "web_identity_principal_id" {
  description = "Principal ID of the web user-assigned managed identity."
  value       = azurerm_user_assigned_identity.web.principal_id
}

output "acr_pull_role_assignment_ids" {
  description = "AcrPull role assignment IDs for application workload identities."
  value = {
    api = azurerm_role_assignment.api_acr_pull.id
    web = azurerm_role_assignment.web_acr_pull.id
  }
}

output "api_key_vault_secret_role_assignment_ids" {
  description = "Key Vault Secrets User role assignment IDs for API-readable PostgreSQL secrets."
  value       = { for secret_name, assignment in azurerm_role_assignment.api_key_vault_secrets_user : secret_name => assignment.id }
}
