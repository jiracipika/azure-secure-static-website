# Architecture: Secure Static Website

Front Door Premium WAF → Private Link → Storage `$web` static site; GitHub
Actions deploys via OIDC-federated Entra identity.

Goal: build a responsive accessible website and enforce HTTPS, WAF, private
origin, and a safe deployment network — all expressed as code, validated
offline, deployed only after explicit approval.

## Module map (implemented in `infra/terraform`)

| Module | Implements | Key controls |
|---|---|---|
| `modules/static_site_storage` | Storage account + `$web` static site (azapi child resource) | `public_network_access_enabled=false`, `https_traffic_only_enabled=true`, TLS 1.2 floor, no shared-key/SAS auth, no public blob ACLs |
| `modules/frontdoor_premium` | AFD profile/endpoint/origin-group/origin/route + WAF policy + security-policy attachment | Premium SKU (required for private origins), HTTP→HTTPS redirect, `HttpsOnly` forwarding, managed rules (DefaultRuleSet 2.1, BotManager 1.0), custom rule blocking unsafe methods, cert name check on origin |
| `modules/github_oidc` | User-assigned identity + federated credential + role assignment | Subject pinned to `repo:…:ref:refs/heads/main`, audience `api://AzureADTokenExchange`, role scoped Storage Blob Data Contributor on this account only |

The root module gates everything behind `deploy_enabled = false` (default), so
`terraform plan` with defaults proposes zero resources.

## Trust boundaries

1. **Public internet** → reaches only the AFD endpoint (443; WAF in
   Prevention mode).
2. **AFD edge → origin**: Private Link to the storage account; storage has no
   public data-plane path.
3. **GitHub CI → ARM control plane**: OIDC federation, `contents: read` on the
   repo, no stored secrets.
4. **GitHub CI → storage data plane**: *not possible from a GitHub-hosted
   runner* because the account is private — see deployment-path decision below.

## Deployment path decision (the known design caveat)

A GitHub-hosted runner cannot upload to a fully private storage account. The
honest options, in preference order:

1. **Self-hosted runner inside a VNet** with a private endpoint on the storage
   account (no public exposure at any time). Recommended for real deployments.
2. **Time-boxed public-network window** with the runner's IP ranges allowed and
   Entra-only auth (no SAS), reverted immediately after upload. Acceptable for a
   one-off lab deploy with approval; weakest of the three.
3. **Upload from an approved operator machine** over a private endpoint/VPN.

Option 2's config is intentionally NOT pre-wired into the modules; it must be an
explicit, reviewed change if ever chosen.

This is a design validated offline, not a deployed system.
