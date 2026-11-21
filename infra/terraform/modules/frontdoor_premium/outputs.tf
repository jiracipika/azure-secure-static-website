output "profile_id" {
  value = azurerm_cdn_frontdoor_profile.this.id
}

output "endpoint_hostname" {
  description = "Public FQDN served by Front Door."
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "firewall_policy_id" {
  value = azurerm_cdn_frontdoor_firewall_policy.this.id
}

output "custom_domain_fqdn" {
  description = "Validated custom hostname; null unless dns_zone_name is set."
  value       = one(module.custom_domain[*].site_fqdn)
}

output "dns_zone_name_servers" {
  description = "Name servers for delegating dns_zone_name; null unless dns_zone_name is set."
  value       = one(module.custom_domain[*].dns_zone_name_servers)
}
