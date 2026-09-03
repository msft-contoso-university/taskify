# Infrastructure

Infrastructure as Code for Taskify, provisioned on Azure.

## Policy: this is scaffolding, not deployed infrastructure

This directory intentionally contains **structure only** — module folders,
environment folders, and starter provider/version configuration. It does
**not** contain fully authored Azure resources, and nothing here has been
applied against a real subscription.

Real Terraform authoring for this repo happens **live, through the agentic
SDLC workflow**, not as a one-off local generation step:

1. A user (or team) opens a GitHub issue describing infrastructure or
   feature requirements (e.g. "provision Postgres + Container Apps for the
   staging environment").
2. The **Issue Triage** agentic workflow (`.github/workflows/issue-triage.lock.yml`)
   labels it, e.g. `infra-request`.
3. A maintainer runs `/plan` on the issue; the **Plan** workflow breaks it
   into concrete sub-tasks/sub-issues.
4. Sub-issues are assigned to **Copilot coding agent**, which is guided by
   the custom agents in `.github/agents/` (`azure-iac-generator`,
   `terraform-azure-implement`, `terraform-iac-reviewer`) and the repo-level
   memory in `.github/copilot-instructions.md`.
5. Copilot coding agent opens a PR with the actual Terraform. The
   **Copilot code review** agent plus a human reviewer approve it before
   merge. `terraform plan` output should be attached to the PR for review;
   `terraform apply` requires explicit human approval and is never run
   unattended.

## Layout

Mirrors the 5-stage structure used by the source Bicep templates this repo's
sample app was ported from, so the mapping from "old Bicep stage" to
"new Terraform module" is obvious:

```
modules/
  foundation/     # Resource group, networking, Key Vault
  data/           # Azure Database for PostgreSQL Flexible Server
  containers/     # Azure Container Registry, Container Apps Environment
  application/     # Container Apps (api, web)
  performance/     # Autoscaling, monitoring, budgets
environments/
  dev/            # Dev environment root module (backend + variables)
  prod/           # Prod environment root module (backend + variables)
```

Each `environments/<env>` folder is a Terraform root module that wires the
`modules/*` together for that environment; `modules/*` are reusable,
composable building blocks and should not be applied directly.

## Azure target

- Subscription ID: `b6f10878-9f8a-4b3f-8bc5-3464cdd79c77`
- Tenant ID: `16b3c013-d300-468d-ac64-7eda0820b6d3`

These are documented here as expected `ARM_SUBSCRIPTION_ID` / `ARM_TENANT_ID`
values (see `versions.tf` for how they're wired as variables). They are not
secrets, but authentication should still use OIDC/service principal via
environment variables — never hardcode credentials in `.tf` files.

## Planning files

`.terraform-planning-files/` (repo root of `/infrastructure`) holds
`INFRA.<goal>.md` planning notes, following the convention used by the
`terraform-azure-implement` custom agent — these capture the intent behind
an infra change before Terraform is authored, and are read by that agent
when it picks up a sub-issue.

## Local validation

Even though no resources are deployed, the scaffold should always pass:

```bash
terraform fmt -check -recursive infrastructure/terraform
terraform -chdir=infrastructure/terraform/environments/dev init -backend=false
terraform -chdir=infrastructure/terraform/environments/dev validate
```

`terraform plan` / `terraform apply` are **not** run as part of this repo's
CI or by any agent without explicit human sign-off.
