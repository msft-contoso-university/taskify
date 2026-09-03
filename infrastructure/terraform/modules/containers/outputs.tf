output "acr_id" {
  description = "ID of the Azure Container Registry."
  value       = azurerm_container_registry.this.id
}

output "acr_name" {
  description = "Name of the Azure Container Registry."
  value       = azurerm_container_registry.this.name
}

output "acr_login_server" {
  description = "Login server URL for image pushes/pulls by downstream modules."
  value       = azurerm_container_registry.this.login_server
}

output "container_app_environment_id" {
  description = "ID of the shared Container Apps Environment."
  value       = azurerm_container_app_environment.this.id
}

output "container_app_environment_name" {
  description = "Name of the shared Container Apps Environment."
  value       = azurerm_container_app_environment.this.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace used by the Container Apps Environment."
  value       = azurerm_log_analytics_workspace.this.id
}

output "acr_pull_role_assignment_ids" {
  description = "Optional AcrPull role assignment IDs, keyed by object ID."
  value       = { for object_id, assignment in azurerm_role_assignment.acr_pull : object_id => assignment.id }
}
