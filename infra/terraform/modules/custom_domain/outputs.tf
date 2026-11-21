output "custom_domain_id" {
  description = "ID passed to the Front Door route for custom-domain serving."
  value       = azurerm_cdn_frontdoor_custom_domain.this.id
}

output "site_fqdn" {
  description = "FQDN of the validated custom hostname record."
  value       = azurerm_dns_cname_record.site.fqdn
}

output "dns_zone_name_servers" {
  description = "Delegate the zone to these name servers at the registrar."
  value       = azurerm_dns_zone.this.name_servers
}

output "validation_token" {
  description = "TXT token for ownership validation when DNS lives outside Azure DNS."
  value       = azurerm_cdn_frontdoor_custom_domain.this.validation_token
}
