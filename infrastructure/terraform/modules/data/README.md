# Data module

Provisions the Taskify data layer for an environment:

- Azure Database for PostgreSQL Flexible Server (dev-sized burstable default)
- private DNS zone and VNet link for private access
- application database (`taskify` by default)
- Key Vault secrets for host/user/password/database and full connection string

This module is designed to consume networking + Key Vault outputs from
`modules/foundation`. By default it uses private VNet integration (no public
network access). Set `use_private_networking = false` to instead expose the
server via public network access gated by firewall rules — this is useful
when the server needs to live in a different Azure region than the shared
VNet (e.g. because the subscription restricts PostgreSQL Flexible Server
provisioning in the VNet's region), since a delegated subnet must be in the
same region as the server it's attached to.

## Inputs

| Name | Description | Default |
|---|---|---|
| `environment` | Environment name used in naming/tags. | n/a |
| `location` | Azure region for resources. May differ from the rest of the environment when `use_private_networking = false`. | n/a |
| `resource_group_name` | Resource group for server and DNS resources. | n/a |
| `use_private_networking` | Attach to the delegated VNet subnet + private DNS (`true`) or use public network access + firewall rules (`false`). | `true` |
| `postgres_delegated_subnet_id` | Delegated PostgreSQL subnet ID from `foundation`. Required only when `use_private_networking = true`. | `null` |
| `virtual_network_id` | VNet ID from `foundation` (used for private DNS link). Required only when `use_private_networking = true`. | `null` |
| `public_access_allow_all_azure_ips` | When `use_private_networking = false`, allow all Azure-internal IPs (0.0.0.0 rule) through the firewall. | `false` |
| `public_network_access_ip_rules` | When `use_private_networking = false`, single IP addresses allowed through the firewall (e.g. the CI runner IP). | `[]` |
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
