# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Azure Container Registry (no VNET binding and/or Private Link)

resource "azurerm_container_registry" "aml_acr" {
  name                     = "${var.prefix}acr${random_string.postfix.result}"
  resource_group_name      = var.resource_group
  location                 = var.location
  sku                      = "Standard"
  admin_enabled            = true
}