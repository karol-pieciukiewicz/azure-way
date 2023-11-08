resource "azurerm_key_vault" "keyvault" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.app_tenant_id
  soft_delete_retention_days = var.soft_delete_retention_days
  sku_name                   = var.sku_name

  enable_rbac_authorization     = true
  public_network_access_enabled = false

  network_acls {
    bypass                     = "None"
    default_action             = "Deny"
  }
}

resource "azurerm_role_assignment" "principal_rbac" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.app_principal_id
}

# private endpoint
resource "azurerm_private_endpoint" "pe_kv" {
  name                = format("pe-%s", var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = format("pse-%s", var.name)
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }

  depends_on = [
    azurerm_role_assignment.principal_rbac
  ]
}
resource "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_role_assignment.principal_rbac,
    azurerm_key_vault.keyvault
  ]
}
resource "azurerm_private_dns_a_record" "pe_kv" {
  name                = var.name
  zone_name           = azurerm_private_dns_zone.kv_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe_kv.private_service_connection[0].private_ip_address]

  depends_on = [
    azurerm_role_assignment.principal_rbac,
    azurerm_key_vault.keyvault
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_vnet_link" {
  name                  = "kv-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns.name
  virtual_network_id    = var.vnet_id

  depends_on = [
    azurerm_role_assignment.principal_rbac,
    azurerm_key_vault.keyvault
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_ado_vnet_link" {
  name                  = "kv-ado-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns.name
  virtual_network_id    = var.ado_vnet_id

  depends_on = [
    azurerm_role_assignment.principal_rbac,
    azurerm_key_vault.keyvault
  ]
}

resource "azurerm_key_vault_secret" "secret_1" {
  name         = "ExpertSummitSecret"
  value        = "AwsomeWork!"
  key_vault_id = azurerm_key_vault.keyvault.id

  depends_on = [ 
    azurerm_role_assignment.principal_rbac,
    azurerm_private_dns_zone_virtual_network_link.kv_dns_ado_vnet_link ,
    azurerm_private_dns_a_record.pe_kv,
    azurerm_private_dns_zone.kv_dns
  ]
}