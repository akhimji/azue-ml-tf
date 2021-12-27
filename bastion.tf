# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

resource "azurerm_public_ip" "bastion_ip" {
  name                = "${var.prefix}-public-ip-bastion"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "jumphost_bastion" {
  name                = "${var.prefix}-bastion-host"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
}