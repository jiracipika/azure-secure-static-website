variable "resource_group_name" {
  type = string
}

variable "dns_zone_name" {
  description = "Public DNS zone to create and validate (e.g. example.com)."
  type        = string
}

variable "subdomain" {
  description = "Host label under the zone that carries the TLS certificate."
  type        = string
  default     = "www"
}

variable "frontdoor_profile_id" {
  description = "Front Door profile that owns the custom domain resource."
  type        = string
}

variable "frontdoor_endpoint_fqdn" {
  description = "Endpoint FQDN the CNAME points at (endpoint_hostname output)."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
