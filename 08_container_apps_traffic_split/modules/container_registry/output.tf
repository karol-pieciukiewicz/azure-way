output "id" {
  value = azurerm_container_registry.cr.id
}

output "name" {
  value = azurerm_container_registry.cr.name
}


output "url" {
  value = azurerm_container_registry.cr.login_server
}

output "password" {
  value = azurerm_container_registry.cr.admin_password
}