# Evidence log

Every entry below is an actual command execution with its real result. Azure
live deployment: **NOT RUN** (no authorization). CI results are for commit
`feat: implement Front Door Premium + private origin modules with security tests`.

## 2026-11-16T13:58Z — local offline battery (GLM/ZCode session)

| Command | Result | Evidence |
|---|---|---|
| `python3 -m unittest discover -s tests` | **PASS** | `Ran 40 tests ... OK` |
| `terraform -chdir=infra/terraform fmt -check -recursive` | **PASS** | exit 0 after fixes |
| `terraform -chdir=infra/terraform init -backend=false -input=false` | **PASS** | azurerm v4.81.0 + azapi v2.13.0 installed |
| `terraform -chdir=infra/terraform validate` | **PASS** | `Success! The configuration is valid.` |

### Failures found and fixed during this run (real history)

1. `fmt -check` failed on `variables.tf`, `versions.tf` (scaffold commits were
   not canonically formatted) — fixed with `terraform fmt -recursive`. This was
   also the root cause of the red "Safe offline checks" badge on all prior
   pushes.
2. `validate` failed: implied provider `hashicorp/azapi` — child modules now
   declare `required_providers` (`Azure/azapi ~> 2.0`).
3. `validate` failed: `cache.enabled` is not a valid `azurerm_cdn_frontdoor_route`
   argument — removed (block presence enables caching).
4. `validate` failed: WAF operator `NotIn` does not exist (allowed set verified
   from provider schema: Any/BeginsWith/Contains/EndsWith/Equal/GeoMatch/IPMatch/
   GreaterThan(LessThan)(OrEqual)/RegEx) — custom rule now blocks unsafe methods
   with `Equal` + explicit method list.
5. `validate` failed: azapi embedded schema rejects `staticWebsite` under
   `Microsoft.Storage/storageAccounts/blobServices` — kept with
   `schema_validation_enabled = false` (same pattern as the official Azure AVM
   storage module); **must be verified at first approved deployment** (CLI
   fallback documented in the module).

GitHub Actions: run status recorded below after pushing this commit.

| Date | Run | Conclusion |
|---|---|---|
| 2026-11-16T13:26Z | 43875751240 (scaffold, pre-fix) | failure — `fmt -check` exit 3 |
| 2026-11-16T13:59Z | 43881111084 (implementation) | failure — `dev.tfvars` untracked (gitignore negation was root-anchored) |
| 2026-11-16T14:00Z | 43881317153 (fix commit d215cb6) | **success — full suite + fmt + init + validate green** |

## 2026-11-16T16:45Z — GitHub Pages demo publishing (free, no Azure)

Added `.github/workflows/pages.yml` (Actions-based Pages publish of `app/`).
Permissions `pages: write` + `id-token: write` exist only in this publish
workflow; `validate.yml` is untouched and still apply-free — verified that
`tests/test_scaffold.py::test_safety_gate` asserts on validate.yml only before
adding the file. Pages site enabled with build_type=workflow; first run
dispatched manually. Cost: $0 (GitHub Pages, public repo). Azure remains NOT
DEPLOYED.

## 2026-11-21T14:20Z — milestone: custom domain (weekly automation run)

| Command | Result | Evidence |
|---|---|---|
| `python3 -m unittest discover -s tests` | **PASS** | `Ran 58 tests ... OK` (40 before + 18 new in `tests/test_custom_domain.py`) |
| `terraform -chdir=infra/terraform fmt -check -recursive` | **PASS** | exit 0 (`FMT_OK`) |
| `terraform -chdir=infra/terraform init -backend=false -input=false` | **PASS** | nested `../custom_domain` module installed |
| `terraform -chdir=infra/terraform validate` | **PASS** | `Success! The configuration is valid.` (no warnings) |

### Failures found and fixed during this run (real history)

1. `validate` failed with **Cycle**: `module.frontdoor.azurerm_cdn_frontdoor_route`
   ↔ `module.custom_domain` — a root-level two-way module wiring (route ←
   custom-domain id; custom domain ← profile/endpoint outputs) is a Terraform
   module-graph cycle even though the resource graph is acyclic. Fixed by
   calling `modules/custom_domain` NESTED from `modules/frontdoor_premium`
   (`source = "../custom_domain"`, `count = var.dns_zone_name != "" ? 1 : 0`).
   Pinned by `tests/test_custom_domain.py::test_no_root_level_custom_domain_module`.
2. `validate` warned `minimum_tls_version` is deprecated (removal in provider
   v5.0) — switched to `minimum_version = "TLS12"` (both attributes verified
   present in the 4.81.0 provider schema; enum values are not schema-exposed,
   so TLS12 must be verified at first deployment).
3. Offline schema extraction first read the wrong provider key
   (`registry.terraform.io/azure/azurerm`; azurerm actually registers as
   `hashicorp/azurerm`) — corrected before any code was written against it.

Schema facts verified offline via `terraform providers schema -json`
(azurerm 4.81.0): route association is the `cdn_frontdoor_custom_domain_ids`
set **attribute** (no nested block); `azurerm_dns_txt_record` takes nested
`record { value }` blocks; the CNAME `record` is a plain attribute; the custom
domain supports `dns_zone_id` (in-zone ownership validation) and a `tls` block
(`certificate_type`, `minimum_version`).

Also added: `examples/workflows/deploy-manual.yml.example` — inert
`workflow_dispatch`-only upload draft (must NEVER live under
`.github/workflows/` without owner approval; pinned by tests). Deployment
status: still NOT DEPLOYED; gated by `deploy_enabled=false` AND empty-string
`dns_zone_name`.
