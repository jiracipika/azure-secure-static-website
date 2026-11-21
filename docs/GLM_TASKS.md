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

## Custom-domain milestone — implemented 2026-11-21 (offline validation green)

- [x] `custom-domain` module: Azure DNS zone + `afdverify` TXT + CNAME + AFD
  custom domain (managed certificate, `minimum_version = "TLS12"`), wired to
  the route via `cdn_frontdoor_custom_domain_ids`. Called NESTED from
  `frontdoor_premium` — root-level mutual wiring is a Terraform module-graph
  Cycle (real failure, docs/VALIDATION.md 2026-11-21). Double-gated:
  `deploy_enabled` AND non-empty `dns_zone_name` (default disabled).
- [x] Manual-trigger-only deploy workflow drafted as
  `examples/workflows/deploy-manual.yml.example` — inert by location,
  `workflow_dispatch`-only, OIDC (no stored secrets), includes the
  private-origin upload caveat from docs/ARCHITECTURE.md.
- [ ] Checkov/tflint CI job (pinned versions) — still deferred, image budget.

## Next milestone (offline, no approval needed)

- Apex (root-domain) support via `azurerm_dns_a_record` +
  `target_resource_id` aliasing to the AFD endpoint — `www`-only today;
  document the trade-off in the module.
- Add the Checkov/tflint job once image budget allows.

## Live deployment (owner approval required first)

- Approve cost quote in docs/COSTS.md, choose deployment path option 1/2/3,
  provide subscription, then execute docs/TEARDOWN.md-listed inventory apply.

## Design caveat (resolved in docs)

Private Storage cannot be uploaded to from an arbitrary GitHub-hosted runner;
the trusted deployment path options and recommendation are documented in
docs/ARCHITECTURE.md. Do not stop after planning: build/test locally.
