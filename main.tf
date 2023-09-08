terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.71.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_id" "storage_account" {
  byte_length = 8
}

locals {
  name_part1 = var.base_resource_name
}

module "rg" {
  source     = "./modules/resource-group"
  name_part1 = local.name_part1
  location   = var.location
}

module "storage" {
  source              = "./modules/storage"
  name_part1          = local.name_part1
  name_part2          = lower(random_id.storage_account.hex)
  location            = var.location
  resource_group_name = module.rg.name
}

module "event-hubs" {
  source                 = "./modules/event-hubs"
  name_part1             = local.name_part1
  location               = var.location
  resource_group_name    = module.rg.name
  capture_account_id     = module.storage.capture_account_id
  capture_container_name = module.storage.capture_container_name
  partition_count        = 20
}

module "simulator" {
  source                   = "./modules/simulator"
  name_part1               = local.name_part1
  location                 = var.location
  resource_group_name      = module.rg.name
  eventHubConnectionString = module.event-hubs.send_primary_connection_string
}


resource "azurerm_stream_analytics_job" "job" {
  name                                     = "xxy"
  resource_group_name                      = module.rg.name
  location                                 = var.location
  streaming_units                          = 1
  events_out_of_order_max_delay_in_seconds = 0
  events_late_arrival_max_delay_in_seconds = 5
  data_locale                              = "en-US"
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Stop"

  transformation_query = <<QUERY
SELECT
    *
INTO
    [blob-stream-output]
FROM
    [blob-stream-input]
QUERY

}

resource "azurerm_stream_analytics_stream_input_blob" "example" {
  name                      = "blob-stream-input"
  stream_analytics_job_name = azurerm_stream_analytics_job.job.name
  resource_group_name       = azurerm_stream_analytics_job.job.resource_group_name
  storage_account_name      = module.storage.name
  storage_account_key       = module.storage.key
  storage_container_name    = "$blobchangefeed"
  path_pattern              = "log"
  date_format               = "yyyy/MM/dd"
  time_format               = "HH"

  serialization {
    type     = "Avro"
  }
}
resource "azurerm_stream_analytics_output_blob" "example" {
  name                      = "blob-stream-output"
  stream_analytics_job_name = azurerm_stream_analytics_job.job.name
  resource_group_name       = azurerm_stream_analytics_job.job.resource_group_name
  storage_account_name      = module.storage.name
  storage_account_key       = module.storage.key
  storage_container_name    = module.storage.capture_container_name
  path_pattern              = "log"
  date_format               = "yyyy/MM/dd"
  time_format               = "HH"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}