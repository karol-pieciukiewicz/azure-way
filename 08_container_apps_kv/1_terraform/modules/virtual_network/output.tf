output "id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "app_subnet_id" {
  value = azurerm_subnet.app_subnet.id
}