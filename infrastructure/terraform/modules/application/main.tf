locals {
  base_name = "${var.name_prefix}-${var.environment}"

  api_container_app_name = coalesce(var.api_container_app_name, "${local.base_name}-api")
  web_container_app_name = coalesce(var.web_container_app_name, "${local.base_name}-web")

  api_image = "${var.acr_login_server}/${var.api_image_repository}:${var.api_image_tag}"
  web_image = "${var.acr_login_server}/${var.web_image_repository}:${var.web_image_tag}"

  postgres_connection_string_container_app_secret_name = "postgres-connection-string"
  api_key_vault_secret_names = toset([
    var.postgres_connection_host_secret_name,
    var.postgres_admin_username_secret_name,
    var.postgres_admin_password_secret_name,
    var.postgres_connection_string_secret_name
  ])

  tags = merge(
    {
      application = var.name_prefix
      environment = var.environment
    },
    var.tags
  )
}

resource "azurerm_user_assigned_identity" "api" {
  name                = "${local.api_container_app_name}-id"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_user_assigned_identity" "web" {
  name                = "${local.web_container_app_name}-id"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_role_assignment" "api_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.api.principal_id
}

resource "azurerm_role_assignment" "web_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.web.principal_id
}

resource "azurerm_role_assignment" "api_key_vault_secrets_user" {
  for_each = local.api_key_vault_secret_names

  scope                = "${var.key_vault_id}/secrets/${each.value}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.api.principal_id
}

resource "azurerm_container_app" "api" {
  name                         = local.api_container_app_name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.api.id]
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.api.id
  }

  secret {
    name                = local.postgres_connection_string_container_app_secret_name
    identity            = azurerm_user_assigned_identity.api.id
    key_vault_secret_id = var.postgres_connection_string_secret_id
  }

  ingress {
    external_enabled = false
    target_port      = var.api_target_port
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "api"
      image  = local.api_image
      cpu    = var.api_cpu
      memory = var.api_memory

      env {
        name  = "PORT"
        value = tostring(var.api_target_port)
      }

      env {
        name  = "AZURE_KEY_VAULT_URL"
        value = var.key_vault_uri
      }

      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.api.client_id
      }

      env {
        name        = "POSTGRES_CONNECTION_STRING"
        secret_name = local.postgres_connection_string_container_app_secret_name
      }

      env {
        name  = "PGDATABASE"
        value = var.postgres_database_name
      }

      env {
        name  = "PGSSLMODE"
        value = "require"
      }
    }
  }

  depends_on = [
    azurerm_role_assignment.api_acr_pull,
    azurerm_role_assignment.api_key_vault_secrets_user
  ]
}

resource "azurerm_container_app" "web" {
  name                         = local.web_container_app_name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.web.id]
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.web.id
  }

  ingress {
    external_enabled = true
    target_port      = var.web_target_port
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "web"
      image  = local.web_image
      cpu    = var.web_cpu
      memory = var.web_memory

      env {
        name  = "API_BASE_URL"
        value = "https://${azurerm_container_app.api.latest_revision_fqdn}"
      }
    }
  }

  depends_on = [
    azurerm_container_app.api,
    azurerm_role_assignment.web_acr_pull
  ]
}
