# Copilot instructions for Taskify

This file is repo-level memory for GitHub Copilot (chat, code review, and
coding agent). It exists so contributors — human or agentic — don't need to
rediscover these conventions from scratch every session.

## What this repo is

Taskify is a demo of the **agentic software development lifecycle (SDLC)**:
requirements come in as a GitHub issue, get triaged and planned by agentic
workflows, and are implemented by Copilot coding agent with human + Copilot
code review before merge. The app itself (a Kanban board) is a realistic
but secondary vehicle for demonstrating that loop — infrastructure requests
are a first-class example of the kind of issue this loop handles.

## Repo layout

```
apps/api/              Node.js + Express REST API (Postgres via `pg`)
apps/web/               React + Vite + TypeScript + Tailwind frontend
sql/                     Postgres schema + seed data, applied via docker-entrypoint-initdb.d
docker-compose.yml         Local dev stack (db, api, web)
infrastructure/            Terraform IaC — see infrastructure/README.md
.github/agents/             Custom Copilot agents for IaC work
.github/workflows/           gh-aw agentic workflows (issue triage, /plan)
```

## Infrastructure policy — read this before touching `/infrastructure`

- **Terraform only.** No Bicep, ARM, or Pulumi in this repo. Bicep exists
  only as historical reference (the app + its original Bicep IaC came from
  another repo) — the mapping from Bicep stage to Terraform module is
  documented in `infrastructure/terraform/modules/*/README.md`.
- **No infrastructure is provisioned by default.** `/infrastructure/terraform`
  currently contains scaffolding only (folders, `versions.tf`, `providers.tf`)
  — no real resources. Real Terraform is authored later, live, through the
  agentic workflow (issue → triage → `/plan` → Copilot coding agent → PR
  review), not generated upfront in bulk.
- **Never run `terraform apply` / `terraform destroy` / any deploying `az`
  command without explicit, in-the-moment human confirmation.** Generating
  and validating (`fmt`, `validate`, `plan`) is always fine; changing real
  cloud resources is not, especially since the target subscription is a
  shared demo environment.
- Azure target for this repo: subscription `b6f10878-9f8a-4b3f-8bc5-3464cdd79c77`,
  tenant `16b3c013-d300-468d-ac64-7eda0820b6d3`. These are already wired as
  Terraform variable defaults in `environments/*/providers.tf` — reference
  the variables, never hardcode the raw IDs in new resource blocks.
- For any Terraform work, prefer the custom agents in `.github/agents/`:
  - `azure-iac-generator` — decides IaC format (always Terraform here) and
    hands off.
  - `terraform-azure-implement` — authors real Terraform resources for an
    infra sub-issue.
  - `terraform-iac-reviewer` — reviews Terraform PRs for state safety,
    security, and modularity.

## Agentic workflow conventions

- Issues describing infra/deployment needs should be labeled `infra-request`
  by the Issue Triage workflow so they're easy to find and route to the
  Terraform agents above.
- Use the `/plan` command on a triaged issue to break it into concrete
  sub-issues before assigning work to Copilot coding agent — don't hand
  large, vague issues directly to the coding agent.
- Every PR should go through **Copilot code review** (GitHub's built-in
  reviewer) in addition to a human reviewer — this is configured at the
  repo level, not as a custom workflow. Terraform PRs additionally get a
  review pass from the `terraform-iac-reviewer` agent.

## App conventions

- Backend reads Postgres credentials from environment variables locally
  (`PGHOST`/`PGUSER`/`PGPASSWORD`/...) and from Azure Key Vault + Managed
  Identity in Azure, toggled by whether `AZURE_KEY_VAULT_URL` is set — keep
  this dual-mode pattern if you touch `apps/api/src/services/database.js`.
- Frontend has no real auth; it's a "pick a user" flow (`UserSelect`) meant
  for demo purposes only — don't add real authentication unless explicitly
  asked, since it's out of scope for this demo.
- Local dev: `docker compose up --build` boots db (seeded via `sql/`), api
  (port 3000), and web (port 5173, proxies `/api` to the api container).

## When in doubt

Prefer asking a clarifying question (or, for agents, leaving it for human
review) over guessing on: anything that touches real Azure resources,
authentication/authorization behavior, or state backend configuration.
