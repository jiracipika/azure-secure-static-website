# Architecture: Secure Static Website

Front Door Premium WAF -> Private Link -> Storage static website; GitHub Actions OIDC.

Goal: Build a responsive accessible website and test HTTPS, WAF, private origin and safe deployment network.

Known implementation risk: Private Storage cannot be uploaded to from an arbitrary GitHub-hosted runner; choose a trusted deployment path.

Workload, Azure control plane, storage/data plane, GitHub CI and public internet are separate trust boundaries. Map ports and credential scopes precisely. This is a design, not a deployed system.
