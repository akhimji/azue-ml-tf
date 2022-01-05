# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Azure Kubernetes Service (not deployed per default)

resource "azurerm_kubernetes_cluster" "aml_aks" {
  #count               = var.deploy_aks ? 1 : 0
  #name                = "${var.prefix}-aks-${random_string.postfix.result}"
  name                = "aml-01-aks"
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "aks"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_DS2_v2"
	  vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = "10.0.4.10"
    service_cidr       = "10.0.4.0/24"
	  docker_bridge_cidr = "172.17.0.1/16"
  }  
  
}

resource "azurerm_machine_learning_inference_cluster" "aml_aks" {
  name                  = "aml-inf-clstr"
  location              = var.location
  cluster_purpose       = "FastProd"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aml_aks.id
  description           = "Inference cluster for AML"

  machine_learning_workspace_id = azurerm_machine_learning_workspace.aml_ws.id

  tags = {
    "stage" = "aml_aks"
  }
  
  depends_on = [azurerm_machine_learning_workspace.aml_ws,azurerm_kubernetes_cluster.aml_aks]

}