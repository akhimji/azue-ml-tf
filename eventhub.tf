resource "azurerm_eventhub_namespace" "aml" {
  name                = "AMLEventHubNamespace"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "Sandbox"
  }
}

resource "azurerm_eventhub" "aml" {
  name                = "acceptanceTestEventHub"
  namespace_name      = azurerm_eventhub_namespace.aml.name
  resource_group_name = var.resource_group
  partition_count     = 2
  message_retention   = 1
}