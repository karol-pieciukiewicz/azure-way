resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "${var.prefix}-app-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage"]

  delegation {
    name = "delegation"

    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_virtual_network_peering" "vnet_ado" {
  name                      = "peering-to-ado-vnet"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = var.ado_vnet_id
}

resource "azurerm_virtual_network_peering" "ado_vnet" {
  name                      = "peering-to-${var.name}"
  resource_group_name       = var.ado_vnet_resource_group
  virtual_network_name      = var.ado_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_subnet" "integration_subnet" {
  name                 = "${var.prefix}-integration-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints = ["Microsoft.Web"]
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = "${var.prefix}-sql-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints = []
}

resource "azurerm_subnet" "pe_subnet" {
  name                 = "${var.prefix}-pe-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "kv_subnet" {
  name                 = "${var.prefix}-kv-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.4.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "cr_agent_pool_subnet" {
  name                 = "${var.prefix}-cr-agent-pool-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.5.0/24"]
  service_endpoints    = []
}
