output "eventhub_namespace_name" {
  value       = azurerm_eventhub_namespace.main.name
  description = "The event hub namespace."
}

output "eventhub_name" {
  value       = azurerm_eventhub.main.name
  description = "The event hub name."
}

output "send_primary_connection_string" {
  value       = azurerm_eventhub_authorization_rule.send.primary_connection_string
  description = "The primary connection string to send events."
  sensitive   = true
}