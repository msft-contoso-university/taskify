# Application module

Scaffold only — no resources defined yet.

Will provision: the `api` and `web` Azure Container Apps (built from
`apps/api` and `apps/web` in this repo), their revisions/ingress, and
Managed Identity bindings for Key Vault access. Mirrors the source repo's
`infrastructure/bicep/4-application.bicep` stage.
