# Custom domain for the Front Door endpoint, served from Azure DNS.
# Validation stays in-zone: Front Door reads the ownership token from the
# afdverify TXT record in this zone (dns_zone_id wiring) instead of requiring
# a manual TXT paste at an external registrar.

locals {
  # Front Door custom domain resource names allow alphanumerics and hyphens.
  frontdoor_domain_name = lower(replace("${var.subdomain}.${var.dns_zone_name}", "/[.]/", "-"))
}

resource "azurerm_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Ownership pre-validation: afdverify.<zone> TXT = validation token.
resource "azurerm_dns_txt_record" "afdverify" {
  name                = "afdverify"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300

  record {
    value = azurerm_cdn_frontdoor_custom_domain.this.validation_token
  }
}

# <subdomain> CNAME -> Front Door endpoint.
resource "azurerm_dns_cname_record" "site" {
  name                = var.subdomain
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.frontdoor_endpoint_fqdn
}

resource "azurerm_cdn_frontdoor_custom_domain" "this" {
  name                     = local.frontdoor_domain_name
  cdn_frontdoor_profile_id = var.frontdoor_profile_id
  host_name                = "${var.subdomain}.${var.dns_zone_name}"

  # Lets Front Door validate ownership from this Azure DNS zone automatically.
  dns_zone_id = azurerm_dns_zone.this.id

  tls {
    certificate_type = "ManagedCertificate"
    minimum_version  = "TLS12" # minimum_tls_version is deprecated (provider v5.0); enum not schema-exposed — verify at first deployment
  }
}
