output "status" {
  description = "Guards against mistaking the offline scaffold for a deployment."
  value       = var.deploy_enabled ? "deployment-configured (requires explicit owner approval to apply)" : "offline-scaffold-only"
}

output "website_endpoint_fqdn" {
  description = "Front Door public hostname; null unless deploy_enabled is true."
  value       = one(module.frontdoor[*].endpoint_hostname)
}

output "deployment_identity_client_id" {
  description = "GitHub Actions OIDC client ID (AZURE_CLIENT_ID); null unless deploy_enabled is true."
  value       = one(module.github_oidc[*].client_id)
}
