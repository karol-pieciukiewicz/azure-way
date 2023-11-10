resource "azurerm_service_plan" "app_plan" {
  name                = "${var.name}-sp"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku
}

resource "azurerm_linux_web_app" "app" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  https_only                = true
  public_network_access_enabled  = false
  virtual_network_subnet_id = var.virtual_network_subnet_id

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    KeyVault_MySecret = "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=${var.key_vault_secret_name})"
  }

  site_config {
    application_stack {
      dotnet_version = var.dotnet_version
    }

    vnet_route_all_enabled = true
    always_on              = true
  }


}


# private endpoint
resource "azurerm_private_endpoint" "pe_wapp" {
  name                = format("pe-%s", var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = format("pse-%s", var.name)
    private_connection_resource_id = azurerm_linux_web_app.app.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}
resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_linux_web_app.app
  ]
}

resource "azurerm_private_dns_a_record" "pe_wapp" {
  name                = var.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe_wapp.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_a_record" "pe_wapp_scm" {
  name                = "${var.name}.scm"
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe_wapp.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "wapp_dns_vnet_link" {
  name                  = "wapp-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.app_vnet_id
}

resource "azurerm_role_assignment" "principal_rbac" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

output "principal_id" {
  value = azurerm_linux_web_app.app.identity[0].principal_id
}
