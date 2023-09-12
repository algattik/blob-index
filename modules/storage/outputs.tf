output "capture_account_id" {
  value = azurerm_storage_account.main.id
}
output "capture_container_name" {
  value = azurerm_storage_container.main.name
}
output "name" {
  value = azurerm_storage_account.main.name
}
output "key" {
  value = azurerm_storage_account.main.primary_access_key
}

output "url" {
  value = azurerm_storage_account.main.primary_blob_endpoint
}