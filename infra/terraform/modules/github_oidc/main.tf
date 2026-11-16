# Deployment identity: GitHub Actions federates to Entra ID via OIDC.
# No secrets are stored; tokens are exchanged per job run.

resource "azurerm_user_assigned_identity" "deploy" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Federate only the repository's main branch. Never widen the subject claim
# (e.g. repo:* or environment:*) without reviewing SECURITY.md.
resource "azurerm_federated_identity_credential" "github_main" {
  name      = "github-main"
  parent_id = azurerm_user_assigned_identity.deploy.id
  audience  = ["api://AzureADTokenExchange"]
  issuer    = "https://token.actions.githubusercontent.com"
  subject   = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
}

# Least-privilege deploy permission: write blobs on this storage account only.
resource "azurerm_role_assignment" "blob_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.deploy.principal_id
}
