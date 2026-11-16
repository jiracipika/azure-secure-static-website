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
