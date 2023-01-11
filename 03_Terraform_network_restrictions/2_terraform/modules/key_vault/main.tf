resource "azurerm_key_vault" "keyvault" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.app_tenant_id
  soft_delete_retention_days = var.soft_delete_retention_days
  sku_name                   = var.sku_name

  public_network_access_enabled = false

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    virtual_network_subnet_ids = var.subnetIds
    ip_rules                   = var.allowed_ips
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_key_vault_access_policy" "policy" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = var.app_tenant_id
  object_id    = var.app_principal_id

  key_permissions         = ["List", "Get", "Delete", "Purge"]
  secret_permissions      = ["List", "Get", "Set", "Delete", "Purge", "Recover"]
  certificate_permissions = ["List", "Get", "Delete", "Purge"]
  storage_permissions     = ["List", "Get", "Delete", "Purge"]
}

# private endpoint
resource "azurerm_private_endpoint" "pe_kv" {
  name                = format("pe-%s", var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnetIds[0]

  private_service_connection {
    name                           = format("pse-%s", var.name)
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }

  depends_on = [
    azurerm_key_vault_access_policy.policy,
    azurerm_key_vault.keyvault
  ]  
}
resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_key_vault_access_policy.policy,
    azurerm_key_vault.keyvault
  ]
}
resource "azurerm_private_dns_a_record" "pe_kv" {
  name                = var.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe_kv.private_service_connection[0].private_ip_address]

  depends_on = [
    azurerm_key_vault_access_policy.policy,
    azurerm_key_vault.keyvault
  ]  
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_vnet_link" {
  name                  = "kv-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.vnet_id

  depends_on = [
    azurerm_key_vault_access_policy.policy,
    azurerm_key_vault.keyvault
  ]  
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_ado_vnet_link" {
  name                  = "kv-ado-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.ado_vnet_id

  depends_on = [
    azurerm_key_vault_access_policy.policy,
    azurerm_key_vault.keyvault
  ]
}