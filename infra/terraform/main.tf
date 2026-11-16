# Root module. All Azure resources are gated behind deploy_enabled (default
# false): with the default variables `terraform plan` proposes zero changes
# outside the placeholder provider configuration.
locals {
  project = "azure-secure-static-website"
  tags    = merge(var.tags, { project = local.project })
}

resource "azurerm_resource_group" "this" {
  count    = var.deploy_enabled ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

module "storage" {
  count                = var.deploy_enabled ? 1 : 0
  source               = "./modules/static_site_storage"
  resource_group_name  = one(azurerm_resource_group.this[*].name)
  location             = var.location
  storage_account_name = var.storage_account_name
  tags                 = local.tags
}

module "frontdoor" {
  count                         = var.deploy_enabled ? 1 : 0
  source                        = "./modules/frontdoor_premium"
  resource_group_name           = one(azurerm_resource_group.this[*].name)
  location                      = var.location
  waf_mode                      = var.waf_mode
  origin_hostname               = one(module.storage[*].web_endpoint_hostname)
  origin_private_link_target_id = one(module.storage[*].storage_account_id)
  tags                          = local.tags
}

module "github_oidc" {
  count               = var.deploy_enabled ? 1 : 0
  source              = "./modules/github_oidc"
  resource_group_name = one(azurerm_resource_group.this[*].name)
  location            = var.location
  github_org          = var.github_org
  github_repo         = var.github_repo
  storage_account_id  = one(module.storage[*].storage_account_id)
  tags                = local.tags
}
