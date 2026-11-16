# Security requirements

No secrets, state, privileged tokens, public SSH/RDP or customer data in git.
Pin or review CI dependencies, scope federated identity narrowly, apply least
privilege, block unauthorized network paths, and log denial tests.

## Implemented controls (as code, enforced by `tests/test_terraform_security.py`)

- Storage origin: HTTPS-only, TLS 1.2 minimum, public network access disabled,
  shared-key/SAS auth disabled, anonymous blob access impossible.
- Edge: HTTP→HTTPS redirect, `HttpsOnly` forwarding to origin, WAF Prevention
  mode with managed rule sets + unsafe-method custom deny, WAF attached to the
  endpoint's default domain.
- Deployment identity: OIDC (no stored secrets), subject pinned to the main
  branch of this repository only, Storage Blob Data Contributor scoped to the
  single storage account.
- CI: `permissions: contents: read`; a regression test asserts no
  `terraform apply`/`destroy` can appear in the workflow.

## Architecture security flaws considered

- **Private-origin upload path** (critical, from the original design): a
  GitHub-hosted runner cannot reach a private storage account. Resolution
  options and recommendation are in docs/ARCHITECTURE.md; nothing insecure is
  pre-wired.
- SAS/shared-key auth removed entirely (`shared_access_key_enabled = false`) —
  Entra ID only.
- WAF mode defaults to Prevention; switching to Detection for testing is a
  single reviewed variable.

## Negative tests

`tests/test_terraform_security.py` fails if any invariant above regresses
(e.g. wildcard OIDC subject, `public_network_access_enabled = true`, apply in
CI). `tests/test_scaffold.py` fails if the deploy guard or no-apply CI gate
regresses.
