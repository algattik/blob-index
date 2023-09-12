data "azurerm_client_config" "current" { }

resource "azurerm_storage_account" "main" {
  name                     = format("st%s%s", var.name_part1, var.name_part2)
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  blob_properties {
    change_feed_enabled = true
  }

}

resource "azurerm_role_assignment" "main" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_container" "main" {
  name                  = "container1"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_blob_inventory_policy" "main" {
  storage_account_id = azurerm_storage_account.main.id
  rules {
    name                   = "rule1"
    storage_container_name = azurerm_storage_container.main.name
    format                 = "Csv"   # Possible values are Csv and Parquet.
    schedule               = "Daily" # Possible values are Daily and Weekly.
    scope                  = "Blob"  #  Possible values are Blob and Container.
    schema_fields = [
      "Name",
      "Last-Modified",
      "Content-Length"
    ]
    filter {
      blob_types = ["blockBlob"]
    }
  }
}