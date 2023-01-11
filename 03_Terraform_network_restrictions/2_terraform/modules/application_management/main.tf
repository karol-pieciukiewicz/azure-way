resource "azurerm_public_ip" "apim-pip" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

  domain_name_label = "${var.name}-dns"
  sku               = "Standard"

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_network_security_group" "apim-nsg" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_network_security_rule" "apim-rule1" {
  name                        = "Client communication to API Management"
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
  name                        = "Management endpoint for Azure portal and PowerShell"
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
  name                        = "Azure Infrastructure Load Balancer"
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

resource "azurerm_network_security_rule" "apim-rule4" {
  name                        = "Dependency on Azure Storage"
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
  name                        = "Access to Azure SQL endpoints"
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
  name                        = "Access to Azure Key Vault"
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
  lifecycle { ignore_changes = [tags] }

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

module "web_app_access_policy" {
  source = "../../modules/key_vault_access_policy"

  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_api_management.apim.identity[0].tenant_id
  object_id    = azurerm_api_management.apim.identity[0].principal_id

  key_permissions         = ["List", "Get"]
  secret_permissions      = ["List", "Get"]
  certificate_permissions = []
  storage_permissions     = []
}

resource "azurerm_api_management_named_value" "apim_crm_dynamics_tenant_key_named_value" {
  name                = "${var.name}-fapp-key"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "${var.name}-fapp-key"
  value_from_key_vault {
    secret_id = var.function_key_id
  }
  secret = true

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_api_management_api_policy" "example" {
  count = var.add_policy_to_azure_function_apim == "True" ? 1 : 0

  api_name            = "Sample_Function_Web_API"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name

  xml_content = <<XML
<policies>
  <inbound>
    <set-header name="x-functions-key" exists-action="override">
        <value>{{${var.name}-fapp-key}}</value>
    </set-header>
  </inbound>
</policies>
XML

  depends_on = [
    azurerm_api_management_named_value.apim_crm_dynamics_tenant_key_named_value
  ]
}

output "name" {
  value = azurerm_api_management.apim.name
}