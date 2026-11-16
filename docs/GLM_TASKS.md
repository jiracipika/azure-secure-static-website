# GLM backlog — Secure Static Website

## Immediate milestone — STATUS: implemented 2026-11-16 (offline validation green)

1. ✅ Confirm the provided architecture and its security flaws → docs/ARCHITECTURE.md
   ("Deployment path decision"), docs/SECURITY.md ("Architecture security flaws considered").
2. ✅ Build offline runnable Terraform modules; `deploy_enabled=false` gates all
   resources (static_site_storage, frontdoor_premium, github_oidc).
3. ✅ Test cases proving HTTPS, WAF, private origin and safe deployment network:
   `tests/test_terraform_security.py` (30 controls), `tests/test_app.py`
   (accessibility/responsiveness), `tests/test_scaffold.py` (safety gates).
4. ✅ terraform fmt/init -backend=false/validate and unittest — real outputs in
   docs/VALIDATION.md, including five failures found and fixed.
5. ✅ Mermaid diagram and README refined to match the implemented code.
6. ✅ Pricing estimate (~$40/mo) in docs/COSTS.md; teardown inventory in
   docs/TEARDOWN.md — awaiting explicit owner review for anything live.

## Next milestone (offline, no approval needed)

- Add a `custom-domain` module (Azure DNS zone + AFD custom domain +
  certificate association) gated by `deploy_enabled`, with tests.
- Draft a manual-trigger-only deploy workflow (workflow_dispatch, OIDC login,
  upload to `$web` from a trusted runner) that stays dormant without secrets.
- Add a Checkov/tflint job to CI (pinned versions) once image budget allows.

## Live deployment (owner approval required first)

- Approve cost quote in docs/COSTS.md, choose deployment path option 1/2/3,
  provide subscription, then execute docs/TEARDOWN.md-listed inventory apply.

## Design caveat (resolved in docs)

Private Storage cannot be uploaded to from an arbitrary GitHub-hosted runner;
the trusted deployment path options and recommendation are documented in
docs/ARCHITECTURE.md. Do not stop after planning: build/test locally.
