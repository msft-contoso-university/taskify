output "resource_group_name" {
  description = "Name of the dev application resource group."
  value       = module.foundation.resource_group_name
}

output "key_vault_uri" {
  description = "URI of the shared dev Key Vault."
  value       = module.foundation.key_vault_uri
}

output "postgresql_fqdn" {
  description = "FQDN of the dev PostgreSQL Flexible Server."
  value       = module.data.postgresql_fqdn
}

output "acr_login_server" {
  description = "Login server for the dev Azure Container Registry."
  value       = module.containers.acr_login_server
}

output "container_app_environment_name" {
  description = "Name of the dev Container Apps Environment."
  value       = module.containers.container_app_environment_name
}

output "api_fqdn" {
  description = "Ingress FQDN for the dev API Container App."
  value       = module.application.api_fqdn
}

output "web_fqdn" {
  description = "Public ingress FQDN for the dev web Container App."
  value       = module.application.web_fqdn
}
