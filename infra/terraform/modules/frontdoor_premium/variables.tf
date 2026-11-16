variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "waf_mode" {
  description = "Detection for observation, Prevention to enforce. Defaults to Prevention per the security contract."
  type        = string
  default     = "Prevention"
}

variable "profile_name" {
  type    = string
  default = "afd-secure-static-website"
}

variable "endpoint_name" {
  description = "Becomes part of the public hostname (<name>-<hash>.z01.azurefd.net); globally unique."
  type        = string
  default     = "afd-secure-static-website-endpoint"
}

variable "origin_group_name" {
  type    = string
  default = "og-static-origin"
}

variable "origin_name" {
  type    = string
  default = "origin-private-storage"
}

variable "route_name" {
  type    = string
  default = "route-static-site"
}

variable "firewall_policy_name" {
  type    = string
  default = "waf-static-site"
}

variable "security_policy_name" {
  type    = string
  default = "secpol-waf-endpoint"
}

variable "origin_hostname" {
  description = "Private static-website endpoint hostname of the storage account."
  type        = string
}

variable "origin_private_link_target_id" {
  description = "Resource ID of the storage account targeted by the private origin."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
