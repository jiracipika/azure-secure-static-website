variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "identity_name" {
  type    = string
  default = "id-github-static-deploy"
}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "storage_account_id" {
  description = "Scope of the deploy identity's blob-write permission."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
