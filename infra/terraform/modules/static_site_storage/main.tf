# Private static-website origin: Storage with public network access disabled.
# Served through Front Door Premium over Private Link (see ../frontdoor_premium).
resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.account_replication_type

  # Security invariants — do not relax without a documented security review:
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false # Entra ID (OIDC) auth only; no SAS keys

  tags = var.tags
}

# The $web static-website feature has no native azurerm resource; it is a
# property of the blobServices child resource, managed with the azapi provider.
# API: Microsoft.Storage/storageAccounts/blobServices@2023-05-01
#
# `staticWebsite` is accepted by the resource provider and used by the official
# Azure AVM storage module, but is not modelled in the azapi-embedded Swagger,
# so schema validation is disabled for this resource. VERIFY at first approved
# deployment that $web provisioning succeeded; fallback command:
#   az storage blob service-properties update --auth-mode login \
#     --account-name <account> --static-website \
#     --index-document index.html --404-document error.html
resource "azapi_resource" "static_website" {
  type                      = "Microsoft.Storage/storageAccounts/blobServices@2023-05-01"
  name                      = "default"
  parent_id                 = azurerm_storage_account.this.id
  schema_validation_enabled = false

  body = {
    staticWebsite = {
      enabled              = true
      indexDocument        = "index.html"
      errorDocument404Path = "error.html"
    }
  }
}
