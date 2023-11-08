resource "azurerm_mssql_server" "sql" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.sql_version
  minimum_tls_version = "1.2"

  public_network_access_enabled = true

  azuread_administrator {
    login_username              = var.admin_username
    object_id                   = var.admin_object_id
    azuread_authentication_only = true
  }

  identity {
    type = "SystemAssigned"
  }


}

resource "azurerm_mssql_database" "db" {
  name         = "${var.name}-todo-db"
  server_id    = azurerm_mssql_server.sql.id
  collation    = var.collation
  license_type = "LicenseIncluded"
  max_size_gb  = 10
  sku_name     = var.db_sku


}


resource "azurerm_mssql_firewall_rule" "admin_ip_rule" {
  name             = "AdminIpFirewallRule"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = var.administrator_ip
  end_ip_address   = var.administrator_ip
}

# private endpoint
resource "azurerm_private_endpoint" "pe_sql" {
  name                = format("pe-%s", var.name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = format("pse-%s", var.name)
    private_connection_resource_id = azurerm_mssql_server.sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}
resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}
resource "azurerm_private_dns_a_record" "pe_sql" {
  name                = var.name
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe_sql.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_vnet_link" {
  name                  = "sql-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_ado_vnet_link" {
  name                  = "sql-ado-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.ado_vnet_id
}

