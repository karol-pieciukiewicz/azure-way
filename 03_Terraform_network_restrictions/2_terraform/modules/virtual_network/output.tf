output "id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "app_subnet_id" {
  value = azurerm_subnet.app_subnet.id
}

output "integration_subnet_id" {
  value = azurerm_subnet.integration_subnet.id
}

output "sql_subnet_id" {
  value = azurerm_subnet.sql_subnet.id
}

output "pe_subnet_id" {
  value = azurerm_subnet.pe_subnet.id
}

output "kv_subnet_id" {
  value = azurerm_subnet.kv_subnet.id
}

output "cr_agent_pool_subnet_id" {
  value = azurerm_subnet.cr_agent_pool_subnet.id
}