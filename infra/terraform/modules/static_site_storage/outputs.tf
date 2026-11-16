output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

# Computed because the $web endpoint hostname is only materialised by the
# staticWebsites child resource, which azurerm does not read back.
output "web_endpoint_hostname" {
  value = "${azurerm_storage_account.this.name}.${var.web_zone_suffix}.web.core.windows.net"
}
