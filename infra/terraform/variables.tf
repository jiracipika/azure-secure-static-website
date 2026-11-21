variable "deploy_enabled" {
  description = "Default-off guard. When false, `terraform plan` shows zero Azure resources."
  type        = bool
  default     = false
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "azure_subscription_id" {
  description = "Target subscription. Placeholder default passes offline validation only."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "resource_group_name" {
  type    = string
  default = "rg-secure-static-website"
}

variable "storage_account_name" {
  description = "Globally unique, 3-24 lowercase alphanumeric characters."
  type        = string
  default     = "stsecurestatic01"
}

variable "github_org" {
  type    = string
  default = "jiracipika"
}

variable "github_repo" {
  type    = string
  default = "azure-secure-static-website"
}

variable "waf_mode" {
  description = "WAF mode: Detection for observation, Prevention to enforce."
  type        = string
  default     = "Prevention"
}

variable "dns_zone_name" {
  description = "Public DNS zone for the custom domain. Empty (default) disables it; example.com is the RFC 2606 reserved test value."
  type        = string
  default     = ""
}

variable "custom_domain_subdomain" {
  description = "Host label under dns_zone_name that serves the site."
  type        = string
  default     = "www"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "portfolio-lab"
    managed_by  = "terraform"
  }
}
