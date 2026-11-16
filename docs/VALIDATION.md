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
