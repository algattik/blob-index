

resource "azurerm_container_group" "container" {
  name                = format("aci-%s", var.name_part1)
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  # dns_name_label      = "aci-label"
  os_type = "Linux"
  # restart_policy      = "Always"
  restart_policy = "Never"

  container {
    name   = "simulator"
    image  = "mcr.microsoft.com/oss/azure-samples/azureiot-telemetrysimulator"
    cpu    = 4
    memory = 2
    environment_variables = {
      EventHubConnectionString = var.eventHubConnectionString
      Variables                = jsonencode([{ "name" : "Temp", "random" : true, "max" : 25, "min" : 23 }, { "name" : "Counter", "min" : 100, "max" : 102 }, { "name" : "DoubleValue", "randomDouble" : true, "min" : 0.22, "max" : 1.25 }])
      DeviceCount              = 1000 # amount of simulated devices (default = 1)
      Interval                 = 10   # interval between each message in milliseconds (default = 1000)
      PartitionKey             = "$.DeviceId"
      MessageCount             = 0

    }
    ports {
      port = 8080
    }
  }
}