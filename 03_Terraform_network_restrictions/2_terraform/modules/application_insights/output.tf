output "instrumentation_key" {
  value = azurerm_application_insights.appinsights.instrumentation_key
}

output "connection_string" {
  value = azurerm_application_insights.appinsights.connection_string
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.log_analytics.id
}

output "name" {
  value = azurerm_application_insights.appinsights.name
}