# Safe cleanup

No deployed resources exist today. When a deployment is approved, this is the
exact resource inventory the root module would create:

1. `azurerm_resource_group.this` — rg-secure-static-website (and everything below)
2. `module.storage`: storage account (LRS), blobServices `default` child (static
   website properties)
3. `module.frontdoor`: AFD profile, endpoint, origin group, origin (private link
   connection), route, firewall policy, security policy
4. `module.github_oidc`: user-assigned identity, federated identity credential,
   Storage Blob Data Contributor role assignment

Teardown procedure (requires explicit owner authorization):

1. Confirm no other project consumes the storage account or identity.
2. `terraform destroy` with `deploy_enabled=true` and the approved tfvars.
3. Verify: portal resource group gone; Private Link endpoint list empty.
4. Check for remnants billable outside the RG (none expected — all resources
   are RG-scoped).
5. Record completion with timestamps in docs/VALIDATION.md.
