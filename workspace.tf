# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Azure Machine Learning Workspace with Private Link

resource "azurerm_machine_learning_workspace" "aml_ws" {
  name                    = "${var.prefix}-ws-${random_string.postfix.result}"
  friendly_name           = var.workspace_display_name
  location                = var.location
  resource_group_name     = var.resource_group
  application_insights_id = azurerm_application_insights.aml_ai.id
  key_vault_id            = azurerm_key_vault.aml_kv.id
  storage_account_id      = azurerm_storage_account.aml_sa.id
  container_registry_id   = azurerm_container_registry.aml_acr.id

  identity {
    type = "SystemAssigned"
  }
}

# Create Compute Resources in AML

resource "azurerm_machine_learning_compute_cluster" "aml_ws" {
  name                          = "cpu-cluster"
  location                      = var.location
  vm_priority                   = "LowPriority"
  vm_size                       = "Standard_DS2_v2"
  machine_learning_workspace_id = azurerm_machine_learning_workspace.aml_ws.id
  subnet_resource_id            = azurerm_subnet.compute_subnet.id
  #vnet-name                    = azurerm_subnet.compute_subnet.virtual_network_name
  #subnet-name                  = azurerm_subnet.compute_subnet.name
  #vnet-resourcegroup-name      = azurerm_subnet.compute_subnet.resource_group_name
  #resource-group               = azurerm_machine_learning_workspace.aml_ws.resource_group_name
  #workspace-name               = azurerm_machine_learning_workspace.aml_ws.name

  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 3
    scale_down_nodes_after_idle_duration = "PT600S" # 30 seconds
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_machine_learning_compute_instance" "aml_ws" {
  name                          = "ml-aml-ws"
  location                      = var.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.aml_ws.id
  virtual_machine_size          = "Standard_DS3_v2"
  subnet_resource_id            = azurerm_subnet.compute_subnet.id
  description                   = "ML Compute"
}


# DNS Zones

resource "azurerm_private_dns_zone" "ws_zone_api" {
  name                = "privatelink.api.azureml.ms"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone" "ws_zone_notebooks" {
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = var.resource_group
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "ws_zone_api_link" {
  name                  = "${random_string.postfix.result}_link_api"
  resource_group_name = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.ws_zone_api.name
  virtual_network_id    = azurerm_virtual_network.aml_vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "ws_zone_notebooks_link" {
  name                  = "${random_string.postfix.result}_link_notebooks"
  resource_group_name = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.ws_zone_notebooks.name
  virtual_network_id    = azurerm_virtual_network.aml_vnet.id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "ws_pe" {
  name                = "${var.prefix}-ws-pe-${random_string.postfix.result}"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = azurerm_subnet.aml_subnet.id

  private_service_connection {
    name                           = "${var.prefix}-ws-psc-${random_string.postfix.result}"
    private_connection_resource_id = azurerm_machine_learning_workspace.aml_ws.id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-ws"
    private_dns_zone_ids = [azurerm_private_dns_zone.ws_zone_api.id, azurerm_private_dns_zone.ws_zone_notebooks.id]
  }

  # Add Private Link after we configured the workspace and attached AKS
  depends_on = [azurerm_machine_learning_compute_instance.aml_ws, azurerm_kubernetes_cluster.aml_aks]
}
