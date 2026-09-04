# Application module

Provisions the Taskify application workloads for one environment:

- API Azure Container App with internal ingress
- Web Azure Container App with external ingress
- User-assigned managed identities for ACR image pulls and Key Vault access
- RBAC assignments for `AcrPull` and API Key Vault secret reads

This module assumes the application images already exist in the ACR created by
`modules/containers`. Image build and push automation is intentionally out of
scope for this EPIC.

## Ingress contract

The API uses internal Container Apps ingress (`external_enabled = false`) and
is reachable only from within the Container Apps Environment. The web app uses
external ingress and is the public entry point for smoke testing.

`web_fqdn` is publicly reachable only when the supplied Container Apps
Environment is configured for public ingress. If the environment is created
with an internal load balancer, the web app still has external app ingress
inside that environment but its FQDN is reachable only from the connected
network. Final `environments/dev` wiring must ensure the environment-level
ingress mode matches the smoke-test requirement.

The web Container App receives `API_BASE_URL` set to the API app's internal
Container Apps ingress URL. The deployable web image for Azure Container Apps
must honor that runtime setting when proxying `/api` requests.

## Secret contract

The API Container App defines a Container Apps secret named
`postgres-connection-string` that references the PostgreSQL connection string
secret ID from `modules/data`. Terraform never accepts or emits the plaintext
connection string. The secret is exposed to the API container only as a secret
environment variable named `POSTGRES_CONNECTION_STRING`.

The current API image also uses `AZURE_KEY_VAULT_URL` and `AZURE_CLIENT_ID` to
read the split host/username/password secrets directly from Key Vault. To keep
that image working without broad vault access, the API managed identity is
granted `Key Vault Secrets User` only on the PostgreSQL secret scopes named by
this module's inputs.

## Inputs

| Name | Description | Default |
|---|---|---|
| `environment` | Environment name used in resource names and tags. | n/a |
| `location` | Azure region for application resources. | n/a |
| `resource_group_name` | Resource group name from `modules/foundation`. | n/a |
| `container_app_environment_id` | Container Apps Environment ID from `modules/containers`. | n/a |
| `acr_id` | ACR resource ID from `modules/containers` for `AcrPull` assignments. | n/a |
| `acr_login_server` | ACR login server from `modules/containers`, used to build image references. | n/a |
| `key_vault_id` | Key Vault ID from `modules/foundation`, used to scope API secret-read RBAC. | n/a |
| `key_vault_uri` | Key Vault URI from `modules/foundation`, passed to the API runtime. | n/a |
| `postgres_connection_host_secret_name` | Key Vault secret name from `modules/data.key_vault_secret_names.host`. | n/a |
| `postgres_admin_username_secret_name` | Key Vault secret name from `modules/data.key_vault_secret_names.admin_username`. | n/a |
| `postgres_admin_password_secret_name` | Key Vault secret name from `modules/data.key_vault_secret_names.admin_password`. | n/a |
| `postgres_connection_string_secret_name` | Key Vault secret name from `modules/data.key_vault_secret_names.connection_string`. | n/a |
| `postgres_connection_string_secret_id` | Key Vault secret ID from `modules/data.key_vault_secret_ids.connection_string`. | n/a |
| `postgres_database_name` | PostgreSQL database name from `modules/data.database_name`. | `taskify` |
| `name_prefix` | Prefix used for resource names. | `taskify` |
| `api_image_repository` | ACR repository name for the API image. | `taskify-api` |
| `api_image_tag` | Existing API image tag in ACR. | `dev` |
| `web_image_repository` | ACR repository name for the web image. | `taskify-web` |
| `web_image_tag` | Existing web image tag in ACR. | `dev` |
| `api_container_app_name` | Optional API Container App name override. | `null` |
| `web_container_app_name` | Optional web Container App name override. | `null` |
| `api_target_port` | Port exposed by the API container. | `3000` |
| `web_target_port` | Port exposed by the web container. | `80` |
| `api_cpu` / `web_cpu` | CPU allocated to each container. | `0.25` |
| `api_memory` / `web_memory` | Memory allocated to each container. | `0.5Gi` |
| `min_replicas` | Minimum replicas for each dev Container App. | `0` |
| `max_replicas` | Maximum replicas for each dev Container App. | `1` |
| `tags` | Additional tags merged with module defaults. | `{}` |

## Outputs

| Name | Consumer contract |
|---|---|
| `api_container_app_id` | API Container App resource ID. |
| `api_container_app_name` | API Container App name. |
| `api_fqdn` | Internal API ingress FQDN. |
| `api_identity_principal_id` | API managed identity principal ID. |
| `web_container_app_id` | Web Container App resource ID. |
| `web_container_app_name` | Web Container App name. |
| `web_fqdn` | Public web ingress FQDN for smoke testing after apply. |
| `web_identity_principal_id` | Web managed identity principal ID. |
| `acr_pull_role_assignment_ids` | `AcrPull` role assignment IDs keyed by workload. |
| `api_key_vault_secret_role_assignment_ids` | API `Key Vault Secrets User` role assignment IDs keyed by secret name. |

## Dev environment integration contract

Issue `msft-contoso-university/taskify#8` owns only this module and its
documentation. Final shared `environments/dev` wiring is owned separately.

Expected future `environments/dev` usage:

```hcl
module "application" {
  source = "../../modules/application"

  environment                  = var.environment
  location                     = var.location
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

  # These images must already be pushed to module.containers.acr_login_server.
  api_image_repository = "taskify-api"
  api_image_tag        = "dev"
  web_image_repository = "taskify-web"
  web_image_tag        = "dev"
}
```
