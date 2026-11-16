# Spend safety

Azure spend authorized to date: **$0**. No apply has been run. Budgets alert
but do not cap spending — the real cap is this file plus the deploy gate.

## Estimated monthly cost if deployed (canadacentral, list prices, VERIFY in
the Azure pricing calculator before approval — figures are indicative)

| Resource | SKU | Estimate (USD/mo) |
|---|---|---|
| Front Door profile | Premium_AzureFrontDoor | ~$35 base + egress/requests |
| WAF policy | Included with AFD Premium | $0 additional base |
| Storage account | Standard LRS, ~1 GB | <$1 |
| Private Link on origin | AFD Premium private origin | included in Premium data processing |
| User-assigned identity + role assignment | n/a | $0 |
| DNS (future milestone: custom domain) | Azure DNS zone | ~$0.50/zone + queries |

Realistic lab floor: **≈ $40/month** while deployed, dominated by AFD Premium.

## Cheaper validated alternative (decision for owner)

Standard_AzureFrontDoor + public-but-HTTPS-only storage origin would drop cost
to ~$5/month but abandons the private-origin control that is the point of this
project. Not recommended for the portfolio; documented as a conscious trade-off.

## Rules

Never run cloud apply, premium gateway provisioning, paid load tests or
production identity changes without a SKU/region quote and explicit owner
approval recorded in this file. `deploy_enabled` stays `false` until then.
