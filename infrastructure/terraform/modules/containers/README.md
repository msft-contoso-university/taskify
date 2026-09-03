# Containers module

Provisions shared container-platform resources for one environment:

- Azure Container Registry (ACR) for image storage
- Log Analytics workspace for Container Apps diagnostics
- Azure Container Apps Environment attached to the delegated subnet from
  `modules/foundation`

This module keeps `admin_enabled = false` on ACR and uses Microsoft Entra
managed identities plus RBAC (`AcrPull`) for image pulls.

## Naming

By default, resources use the `taskify-<environment>-*` convention used by
`modules/foundation`. For `dev`, the default names include:

- `taskifydevacr` (ACR name omits hyphens due Azure naming rules)
- `taskify-dev-law`
- `taskify-dev-cae`

## Why Log Analytics is in this module

The Log Analytics workspace is created here (instead of `foundation`) because
it is coupled directly to the Container Apps Environment diagnostics contract,
and this execution boundary is scoped to `modules/containers` only.

## Inputs

| Name | Description | Default |
|---|---|---|
| `environment` | Environment name used in resource names and tags. | n/a |
| `location` | Azure region for resources. | n/a |
| `resource_group_name` | Resource group name from `modules/foundation`. | n/a |
| `container_apps_subnet_id` | Delegated subnet ID from `modules/foundation.subnet_ids.container_apps`. | n/a |
| `name_prefix` | Prefix used for resource names. | `taskify` |
| `acr_name` | Optional ACR name override for global uniqueness. | `null` |
| `acr_sku` | ACR SKU for dev (`Basic` or `Standard`). | `Basic` |
| `container_app_environment_name` | Optional Container Apps Environment name override. | `null` |
| `log_analytics_workspace_name` | Optional Log Analytics workspace name override. | `null` |
| `acr_pull_principal_ids` | Optional object IDs granted `AcrPull` on ACR. | `[]` |
| `tags` | Additional tags merged with module defaults. | `{}` |

## Outputs

| Name | Consumer contract |
|---|---|
| `acr_id` | ACR resource ID for RBAC role assignments and diagnostics wiring. |
| `acr_name` | ACR name for operational references. |
| `acr_login_server` | Required by `modules/application` to configure image references. |
| `container_app_environment_id` | Required by `modules/application` to deploy Container Apps into this shared environment. |
| `container_app_environment_name` | Container Apps Environment name for operational references. |
| `log_analytics_workspace_id` | Log Analytics workspace ID used by the Container Apps Environment. |
| `acr_pull_role_assignment_ids` | Optional `AcrPull` role assignment IDs keyed by object ID. |

## Dev environment integration contract

Issue `msft-contoso-university/taskify#7` owns authoring this module.
Environment wiring remains owned by the environment stack issue; consume
`modules/foundation` outputs through interfaces and do not reconstruct names.

Expected future `environments/dev` usage:

```hcl
module "containers" {
  source = "../../modules/containers"

  environment              = var.environment
  location                 = var.location
  resource_group_name      = module.foundation.resource_group_name
  container_apps_subnet_id = module.foundation.subnet_ids.container_apps

  # Optional: grant AcrPull to workload identities
  # acr_pull_principal_ids = [module.application.api_identity_principal_id]
}
```

`modules/application` should consume:

- `module.containers.acr_login_server`
- `module.containers.container_app_environment_id`

and should grant `AcrPull` to each workload identity either by passing principal
IDs to `acr_pull_principal_ids` here, or by explicit role assignments scoped to
`module.containers.acr_id`.
