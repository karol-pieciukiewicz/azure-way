resource "azurerm_container_registry" "cr" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku                           = var.sku
  admin_enabled                 = true
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }
}