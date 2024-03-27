resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "${var.prefix}-app-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = var.subnet_address_prefix_map["app"]

  delegation {
    name = "delegation"

    service_delegation {
      actions = [
                "Microsoft.Network/virtualNetworks/subnets/join/action",
                ]
      name = "Microsoft.App/environments"
    }
  }
}