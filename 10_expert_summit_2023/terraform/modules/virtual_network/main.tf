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
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints    = []

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_virtual_network_peering" "vnet_ado" {
  name                      = "peering-to-ado-vnet"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = var.ado_vnet.id
}

resource "azurerm_virtual_network_peering" "ado_vnet" {
  name                      = "peering-to-${var.name}"
  resource_group_name       = var.ado_vnet.resource_group_name
  virtual_network_name      = var.ado_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_subnet" "integration_subnet" {
  name                 = "${var.prefix}-integration-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = []
}

resource "azurerm_subnet" "pe_subnet" {
  name                 = "${var.prefix}-pe-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = []
}