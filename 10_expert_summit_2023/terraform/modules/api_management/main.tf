resource "azurerm_public_ip" "apim-pip" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

  domain_name_label = "${var.name}-dns"
  sku               = "Standard"


}

resource "azurerm_network_security_group" "apim-nsg" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name


}

resource "azurerm_network_security_rule" "apim-rule1" {
  name                        = "Client-communication-to-API-Management"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = "Internet"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.apim-nsg.name
}

resource "azurerm_network_security_rule" "apim-rule2" {
  name                        = "Management-endpoint-for-Azure-portal-and-PowerShell"
  priority                    = 350
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["3443"]
  source_address_prefix       = "ApiManagement"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.apim-nsg.name
}

resource "azurerm_network_security_rule" "apim-rule3" {
  name                        = "Azure-Infrastructure-Load-Balancer"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["6390"]
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.apim-nsg.name
}

resource "azurerm_network_security_rule" "apim-rule7" {
  name                        = "Azure-Traffic-Manager-routing-for-multi-region-deployment"
  priority                    = 420
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443"]
  source_address_prefix       = "AzureTrafficManager"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.apim-nsg.name
}

resource "azurerm_network_security_rule" "apim-rule4" {
  name                        = "Dependency-on-Azure-Storage"
  priority                    = 450
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Storage"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.apim-nsg.name
}

resource "azurerm_network_security_rule" "apim-rule5" {
  name                        = "Access-to-Azure-SQL-endpoints"
  priority                    = 500
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["1433"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "SQL"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.apim-nsg.name
}

resource "azurerm_network_security_rule" "apim-rule6" {
  name                        = "Access-to-Azure-Key-Vault"
  priority                    = 550
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureKeyVault"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.apim-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "apim_nsg_association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.apim-nsg.id
}

resource "azurerm_api_management" "apim" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  public_ip_address_id = azurerm_public_ip.apim-pip.id

  virtual_network_type = var.virtual_network_type

  virtual_network_configuration {
    subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  sku_name = var.sku_name


  depends_on = [
    azurerm_network_security_rule.apim-rule1,
    azurerm_network_security_rule.apim-rule2,
    azurerm_network_security_rule.apim-rule3,
    azurerm_network_security_rule.apim-rule4,
    azurerm_network_security_rule.apim-rule5,
    azurerm_network_security_rule.apim-rule6,
    azurerm_network_security_group.apim-nsg,
    azurerm_subnet_network_security_group_association.apim_nsg_association
  ]
}

output "name" {
  value = azurerm_api_management.apim.name
}