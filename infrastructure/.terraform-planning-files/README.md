# Planning notes for infrastructure changes

This folder holds `INFRA.<goal>.md` files — short planning documents that
capture the *intent* behind an infrastructure change before any Terraform is
authored. They're read by the `terraform-azure-implement` custom Copilot
agent (see `.github/agents/terraform-azure-implement.md`) so it has context
on what a sub-issue is trying to achieve, not just the literal issue text.

## Convention

- One file per infra goal: `INFRA.<short-goal-name>.md`
- Created by whoever runs `/plan` on an `infra-request` issue, or by the
  agent itself as a first step when picking up a sub-issue.
- Should cover: goal, affected module(s) under `infrastructure/terraform/modules`,
  target environment(s), and any constraints (region, SKU, budget, compliance).

This folder is intentionally empty in the base scaffold — the first real
file will be created the first time an `infra-request` issue is planned.
