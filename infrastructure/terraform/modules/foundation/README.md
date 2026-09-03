# Foundation module

Provisions the shared Azure foundation for an environment:

- application resource group, separate from the Terraform state resource group
- virtual network
- delegated subnet for Azure Container Apps Environment
- delegated subnet for Azure Database for PostgreSQL Flexible Server
- subnet reserved for future private endpoints
- RBAC-mode Key Vault for secrets created by later modules

No secrets are created by this module.

## Naming

By default, resources use the `taskify-<environment>-*` convention. For `dev`,
the default names include:

- `taskify-dev-rg`
- `taskify-dev-vnet`
- `taskify-dev-cae-snet`
- `taskify-dev-postgres-snet`
- `taskify-dev-private-endpoints-snet`
- `taskifydevkv`

The Key Vault name omits hyphens to satisfy Azure Key Vault naming rules.

## Inputs

| Name | Description | Default |
|---|---|---|
| `environment` | Environment name used in resource names and tags. | n/a |
| `location` | Azure region for resources. | n/a |
| `name_prefix` | Prefix used for foundation resource names. | `taskify` |
| `resource_group_name` | Optional resource group override. | `null` |
| `key_vault_name` | Optional Key Vault name override for global uniqueness. | `null` |
| `vnet_address_space` | Virtual network CIDR ranges. | `["10.42.0.0/16"]` |
| `container_apps_subnet_address_prefixes` | Container Apps delegated subnet CIDRs. | `["10.42.0.0/23"]` |
| `postgres_subnet_address_prefixes` | PostgreSQL delegated subnet CIDRs. | `["10.42.2.0/24"]` |
| `private_endpoints_subnet_address_prefixes` | Reserved private endpoint subnet CIDRs. | `["10.42.3.0/24"]` |
| `key_vault_sku_name` | Key Vault SKU, `standard` or `premium`. | `standard` |
| `key_vault_purge_protection_enabled` | Enables Key Vault purge protection. | `false` |
| `key_vault_public_network_access_enabled` | Enables public network access to Key Vault. | `false` |
| `key_vault_secret_officer_object_ids` | Optional object IDs granted `Key Vault Secrets Officer` on the vault. | `[]` |
| `tags` | Additional tags merged with module defaults. | `{}` |

## Outputs

| Name | Consumer contract |
|---|---|
| `resource_group_id` | Resource group ID for downstream dependencies. |
| `resource_group_name` | Resource group name for `data`, `containers`, and `application` modules. |
| `virtual_network_id` | Virtual network ID for private DNS/network integrations. |
| `virtual_network_name` | Virtual network name for downstream subnet lookups if needed. |
| `subnet_ids.container_apps` | Subnet ID for the Container Apps Environment module. |
| `subnet_ids.postgres` | Subnet ID for the PostgreSQL Flexible Server module. |
| `subnet_ids.private_endpoints` | Subnet ID reserved for later private endpoint modules. |
| `subnet_names` | Subnet names keyed the same way as `subnet_ids`. |
| `key_vault_id` | Key Vault ID for RBAC role assignments and secret creation by later modules. |
| `key_vault_name` | Key Vault name for secret resources and diagnostics. |
| `key_vault_uri` | Key Vault URI for applications that need vault references. |
| `key_vault_secret_officer_role_assignment_ids` | Optional secret-officer role assignment IDs, keyed by object ID. |

## Dev environment integration contract

Issue `msft-contoso-university/taskify#9` owns wiring this module into
`environments/dev`. The expected future module call is:

```hcl
module "foundation" {
  source      = "../../modules/foundation"
  environment = var.environment
  location    = var.location
}
```

Later modules should consume this module's outputs directly instead of
reconstructing resource names.

Because the Key Vault uses RBAC authorization, any later module that creates
`azurerm_key_vault_secret` resources needs a data-plane role such as
`Key Vault Secrets Officer` scoped to `key_vault_id`. Pass the Terraform
deployment principal or another secrets-management principal through
`key_vault_secret_officer_object_ids`, or assign the equivalent role outside
this module before creating secrets.

Public network access is disabled by default and the vault firewall denies by
default. Future secret-creating modules must run from an allowed network path
(for example, a private endpoint or approved runner network) or explicitly opt
into public network access during environment integration.
