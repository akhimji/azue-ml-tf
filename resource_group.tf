# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

resource "azurerm_resource_group" "ak-ml-rg" {
  name     = var.resource_group
  location = var.location
}
