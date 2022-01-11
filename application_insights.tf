# Application Insights for Azure Machine Learning (no Private Link/VNET integration)

resource "azurerm_application_insights" "aml_ai" {
  name                = "${var.prefix}-ai-${random_string.postfix.result}"
  location            = var.location
  resource_group_name = var.resource_group
  application_type    = "web"
}