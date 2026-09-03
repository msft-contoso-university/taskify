# Enabling Copilot code review

This repo relies on GitHub's **built-in Copilot code review** as an
automatic PR reviewer — not a custom agentic workflow. It complements (does
not replace) human review, and for Terraform changes, the
`terraform-iac-reviewer` custom agent (`.github/agents/terraform-iac-reviewer.md`).

## One-time setup (requires repo admin)

Copilot code review auto-request is configured as a **repository ruleset**,
not a file in this repo, so it must be enabled once via the GitHub UI or API
by an admin:

1. Go to **Settings → Rules → Rulesets** in the `taskify` repo.
2. Create a new branch ruleset (or edit an existing one) targeting the
   default branch.
3. Under **Rules**, enable **Require Copilot code review** (sometimes shown
   as "Automatically request Copilot review of new pull requests").
4. Set enforcement to **Active** and save.

Equivalently, via the API (requires admin token):

```bash
gh api -X POST repos/msft-contoso-university/taskify/rulesets \
  -f name="Require Copilot code review" \
  -f target="branch" \
  -f enforcement="active" \
  -f 'conditions[ref_name][include][]=~DEFAULT_BRANCH' \
  -f 'rules[][type]=pull_request' \
  -f 'rules[][parameters][automatic_copilot_code_review_enabled]=true'
```

(Exact field names may change as this GitHub feature evolves — check
`gh api repos/{owner}/{repo}/rulesets --help` / the
[repository rules API docs](https://docs.github.com/rest/repos/rules) for
the current schema if the above is rejected.)

## What this gives us in the agentic SDLC loop

Once enabled, every PR opened by Copilot coding agent (from a `/plan`
sub-issue) automatically gets:

1. An automatic **Copilot code review** comment/review.
2. A required **human reviewer** approval (via normal branch protection).
3. For any PR touching `infrastructure/terraform/**`, an additional review
   pass from the `terraform-iac-reviewer` custom agent (invoke it manually
   or via a follow-up prompt to Copilot coding agent/chat).

This was intentionally left as a repo *setting* rather than a custom
workflow file, per this repo's approach of using GitHub's native review
tooling wherever it already covers the need.
