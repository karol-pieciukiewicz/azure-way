resource "azurerm_container_registry" "cr" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku                           = var.sku
  admin_enabled                 = true
  public_network_access_enabled = false

  network_rule_set {
    default_action = "Deny"

    virtual_network {
      action    = "Allow"
      subnet_id = var.subnet_id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle { ignore_changes = [tags] }
}

# private endpoint
resource "azurerm_private_endpoint" "pe_cr" {
  name                = format("pe-%s", var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = format("pse-%s", var.name)
    private_connection_resource_id = azurerm_container_registry.cr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  depends_on = [
    azurerm_container_registry.cr
  ]
}
resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_container_registry.cr
  ] 
}
resource "azurerm_private_dns_a_record" "pe_cr" {
  name                = replace(azurerm_private_endpoint.pe_cr.custom_dns_configs[0].fqdn, ".azurecr.io", "")
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe_cr.custom_dns_configs[0].ip_addresses[0]]

  depends_on = [
    azurerm_container_registry.cr
  ]
}
resource "azurerm_private_dns_a_record" "pe_data_cr" {
  name                = replace(azurerm_private_endpoint.pe_cr.custom_dns_configs[1].fqdn, ".azurecr.io", "")
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe_cr.custom_dns_configs[1].ip_addresses[0]]

depends_on = [
    azurerm_container_registry.cr
  ]
}
resource "azurerm_private_dns_zone_virtual_network_link" "cr_dns_vnet_link" {
  name                  = "cr-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.vnet_id

depends_on = [
    azurerm_container_registry.cr
  ]  
}

resource "azurerm_private_dns_zone_virtual_network_link" "cr_dns_ado_vnet_link" {
  name                  = "cr-ado-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.ado_vnet_id

depends_on = [
    azurerm_container_registry.cr
  ]  
}

resource "azurerm_container_registry_agent_pool" "private_pool" {
  name                    = "${var.name}pool"
  resource_group_name     = var.resource_group_name
  location                = var.location
  container_registry_name = azurerm_container_registry.cr.name

  tier = var.agent_pool_tier

  virtual_network_subnet_id = var.agnet_pool_subnet_id

}

