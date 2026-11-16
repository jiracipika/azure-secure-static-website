output "client_id" {
  description = "Use as AZURE_CLIENT_ID in the GitHub Actions login step."
  value       = azurerm_user_assigned_identity.deploy.client_id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.deploy.principal_id
}

output "federated_subject" {
  value = azurerm_federated_identity_credential.github_main.subject
}
