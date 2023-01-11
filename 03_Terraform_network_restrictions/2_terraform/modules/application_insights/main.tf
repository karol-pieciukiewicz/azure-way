resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_days

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_application_insights" "appinsights" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
  application_type    = var.application_type

  lifecycle { ignore_changes = [tags] }
}