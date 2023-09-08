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
