# Data module

Provisions the Taskify data layer for an environment:

- Azure Database for PostgreSQL Flexible Server (dev-sized burstable default)
- private DNS zone and VNet link for private access
- application database (`taskify` by default)
- Key Vault secrets for host/user/password/database and full connection string

This module is designed to consume networking + Key Vault outputs from
`modules/foundation` and does not enable public network access.

## Inputs

| Name | Description | Default |
|---|---|---|
| `environment` | Environment name used in naming/tags. | n/a |
| `location` | Azure region for resources. | n/a |
| `resource_group_name` | Resource group for server and DNS resources. | n/a |
| `postgres_delegated_subnet_id` | Delegated PostgreSQL subnet ID from `foundation`. | n/a |
| `virtual_network_id` | VNet ID from `foundation` (used for private DNS link). | n/a |
| `key_vault_id` | Key Vault ID from `foundation` for secret storage. | n/a |
| `name_prefix` | Naming prefix. | `taskify` |
| `server_name` | Optional PostgreSQL server name override. | `null` |
| `private_dns_zone_name` | Optional private DNS zone override (`*.postgres.database.azure.com`). | `null` |
| `postgres_version` | PostgreSQL major version. | `16` |
| `sku_name` | Flexible Server SKU (burstable by default). | `B_Standard_B1ms` |
| `storage_mb` | Storage in MB. | `32768` |
| `backup_retention_days` | Backup retention days. | `7` |
| `administrator_login` | PostgreSQL admin username. Password is always generated. | `taskifyadmin` |
| `database_name` | Application database to create. | `taskify` |
| `connection_host_secret_name` | Key Vault secret name for server host. | `postgresql-connection-host` |
| `admin_username_secret_name` | Key Vault secret name for admin username. | `postgresql-admin-username` |
| `admin_password_secret_name` | Key Vault secret name for generated admin password. | `postgresql-admin-password` |
| `database_name_secret_name` | Key Vault secret name for DB name. | `postgresql-database-name` |
| `connection_string_secret_name` | Key Vault secret name for full PostgreSQL connection string. | `postgresql-connection-string` |
| `tags` | Additional tags merged with defaults. | `{}` |

## Outputs

No plaintext credentials are output.

| Name | Consumer contract |
|---|---|
| `postgresql_server_id` | Flexible Server resource ID. |
| `postgresql_server_name` | Flexible Server name. |
| `postgresql_fqdn` | Server host name for diagnostics and integrations. |
| `database_name` | Created application database name. |
| `private_dns_zone_id` | Private DNS zone ID for downstream network dependencies. |
| `key_vault_secret_names` | Secret names for host, admin username, admin password, database name, and connection string. |
| `key_vault_secret_ids` | Secret IDs for the same values above. |

## Dev environment integration contract

Per issue boundary, this module owns only `modules/data`; environment wiring
is done separately. `environments/dev` should consume this module through the
existing `foundation` outputs, for example:

```hcl
module "data" {
  source = "../../modules/data"

  environment                = var.environment
  location                   = var.location
  resource_group_name        = module.foundation.resource_group_name
  postgres_delegated_subnet_id = module.foundation.subnet_ids.postgres
  virtual_network_id         = module.foundation.virtual_network_id
  key_vault_id               = module.foundation.key_vault_id
}
```

`modules/application` should consume `key_vault_secret_names.connection_string`
(or the explicit secret-name outputs) and use a Key Vault secret reference at
runtime, rather than taking a plaintext connection string Terraform output.
