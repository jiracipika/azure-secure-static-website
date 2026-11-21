# 01 — Secure Static Website

**Azure Cloud Engineering Portfolio** · [GitHub: jiracipika](https://github.com/jiracipika) · **PUBLIC repository** · **Offline scaffold / Azure NOT DEPLOYED**

## Goal
Build an accessible static website and validate secure delivery and private origin connectivity.

## Architecture (implemented as code, gated off)
Azure Front Door Premium (WAF Prevention, HTTP→HTTPS redirect) → Private Link →
Storage `$web` static site (public access disabled, Entra-only auth).
GitHub Actions deploys through an OIDC-federated identity pinned to `main`.

## GLM / ZCode — start here

1. Read [AGENTS.md](AGENTS.md), [GLM tasks](docs/GLM_TASKS.md), [architecture](docs/ARCHITECTURE.md), [security](docs/SECURITY.md), and [validation](docs/VALIDATION.md).
2. Implement the next offline milestone in **docs/GLM_TASKS.md** with runnable code and negative tests, not just a plan.
3. Verify Terraform syntax and security, run unit tests, record actual results, and keep diagrams/documentation current.
4. **Do not apply Terraform or deploy any billable Azure resources or alter cloud IAM without my explicit approval.**
5. Report changed files, actual tests and blockers in your ZCode session and commits.

## Offline starting commands

```sh
python3 -m unittest discover -s tests -v
terraform -chdir=infra/terraform fmt -check -recursive
terraform -chdir=infra/terraform init -backend=false -input=false
terraform -chdir=infra/terraform validate
```

All four pass locally (58 tests) and in CI; see docs/VALIDATION.md for the real
output log, including the failures that were found and fixed.

## Source contents

- `AGENTS.md`: enforceable GLM implementation contract
- `docs/GLM_TASKS.md`: project-specific milestones and current status
- `docs/ARCHITECTURE.md`: topology, trust boundaries, deployment-path decision
- `docs/SECURITY.md` / `docs/COSTS.md`: controls, guardrails, cost estimate (~$40/mo if deployed)
- `docs/VALIDATION.md`: real evidence only — actual commands and results
- `docs/TEARDOWN.md`: resource inventory + approved cleanup plan
- `diagrams/architecture.mmd`: editable Mermaid model with trust boundaries
- `infra/terraform/`: root module + `modules/static_site_storage`, `modules/frontdoor_premium` (nests `modules/custom_domain`: Azure DNS + managed-TLS custom hostname), `modules/github_oidc`; everything gated by `deploy_enabled=false`
- `infra/terraform/environments/dev.tfvars`: offline-safe defaults
- `.github/workflows/validate.yml`: offline validation, no deploy step
- `tests/`: scaffold gates + 58-test security/accessibility/custom-domain regression suite
- `app/`: responsive accessible demo website (index + 404 page)

## Status and safety

Terraform modules for the full target architecture are implemented and
validated offline; **no Azure services are deployed** and `terraform plan`
with defaults proposes zero resources. Repository visibility must remain
**PUBLIC**. No credentials, secrets, real customer data, Terraform state or
internal account identifiers may be committed.
