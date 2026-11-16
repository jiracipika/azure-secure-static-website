variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  description = "Globally unique, 3-24 lowercase alphanumeric characters."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "account_replication_type" {
  description = "LRS is the cost-floor default for a portfolio lab; upgrade per durability requirements."
  type        = string
  default     = "LRS"
}

variable "web_zone_suffix" {
  description = "Regional zone family of the static-website endpoint (z1/z2/z3), e.g. canadacentral -> z1. Must match the storage account region."
  type        = string
  default     = "z1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
