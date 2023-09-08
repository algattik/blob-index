resource "azurerm_eventhub_namespace" "main" {
  name                = format("evh-%s", var.name_part1)
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = var.capacity
}

resource "azurerm_eventhub" "main" {
  name                = "ingestion"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = 1

  capture_description {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 60

    destination {
      name = "EventHubArchive.AzureBlockBlob"

      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}-{Month}-{Day}/{Hour}/{Minute}:{Second}"
      storage_account_id  = var.capture_account_id
      blob_container_name = var.capture_container_name
    }
  }
}

resource "azurerm_eventhub_authorization_rule" "send" {
  name                = "Send"
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.main.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}
