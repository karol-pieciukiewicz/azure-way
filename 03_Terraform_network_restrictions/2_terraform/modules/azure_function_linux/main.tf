resource "azurerm_storage_account" "functionSa" {
  name                            = "${var.params.prefixSafe}sa"
  resource_group_name             = var.resource_group_name
  location                        = var.resource_group_location
  account_tier                    = var.params.storage_account_tier
  account_replication_type        = var.params.storage_account_replication_type
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = ["${var.params.virtual_network_subnet_id}"]
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_service_plan" "functionPlan" {
  name                = "${var.params.prefix}-sp"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  os_type             = "Linux"
  sku_name            = var.params.service_plan_sku

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_linux_function_app" "functionApp" {
  name                = "${var.params.prefix}-fapp"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  storage_account_name       = azurerm_storage_account.functionSa.name
  storage_account_access_key = azurerm_storage_account.functionSa.primary_access_key
  service_plan_id            = azurerm_service_plan.functionPlan.id
  virtual_network_subnet_id  = var.params.virtual_network_subnet_id
  https_only                 = true

  site_config {
    application_insights_key               = var.params.application_insights_instrumentation_key
    application_insights_connection_string = var.params.application_insights_connection_string
    vnet_route_all_enabled                 = true

    application_stack {
      dotnet_version              = var.params.dotnet_version
      use_dotnet_isolated_runtime = true
    }
    ip_restriction {
      virtual_network_subnet_id = var.params.parent_subnet_id
    }
    ip_restriction {
      virtual_network_subnet_id = var.params.ado_subnet_id
    }
  }

  identity {
    type = var.params.functionIdentityType
  }

  lifecycle { ignore_changes = [tags] }
}

module "web_app_access_policy" {
  source = "../../modules/key_vault_access_policy"

  key_vault_id = var.params.keyVaultId
  tenant_id    = var.params.tenantId
  object_id    = azurerm_linux_function_app.functionApp.identity[0].principal_id

  key_permissions         = ["List", "Get"]
  secret_permissions      = ["List", "Get"]
  certificate_permissions = []
  storage_permissions     = []
}

data "azurerm_function_app_host_keys" "app" {
  name                = "${var.params.prefix}-fapp"
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_linux_function_app.functionApp
  ]
}

resource "azurerm_key_vault_secret" "app_key" {
  name         = "${var.params.prefix}-key"
  value        = data.azurerm_function_app_host_keys.app.default_function_key
  key_vault_id = var.params.keyVaultId
}

# private endpoint
resource "azurerm_private_endpoint" "pe_sa_func" {
  name                = "pe-${var.params.prefixSafe}sa"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.params.private_endpoint_subnet_id

  private_service_connection {
    name                           = "pse-${var.params.prefixSafe}sa"
    private_connection_resource_id = azurerm_storage_account.functionSa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_a_record" "pe_sa_func" {
  name                = "${var.params.prefixSafe}sa"
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.pe_sa_func.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_dns_vnet_link" {
  name                  = "sa-vnet-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.params.vnet_id
}

variable "params" {
  type = object({
    prefix                                   = string
    prefixSafe                               = optional(string)
    service_plan_sku                         = optional(string)
    storage_account_tier                     = optional(string)
    storage_account_replication_type         = optional(string)
    log_analytics_sku                        = optional(string) #"PerGB2018"
    log_analytics_retenction_in_days         = optional(number) #30
    application_insights_instrumentation_key = string
    application_insights_connection_string   = string
    functionIdentityType                     = string
    keyVaultId                               = string
    keyVaultName                             = string
    tenantId                                 = string
    vnet_id                                  = string
    virtual_network_subnet_id                = string
    private_endpoint_subnet_id               = string
    parent_subnet_id                         = string
    ado_subnet_id                            = string
    application_insights_name                = string
    dotnet_version                           = string
  })
}

output "service_plan_id" {
  value = azurerm_service_plan.functionPlan.id
}

output "app_key_secret_id" {
  value = azurerm_key_vault_secret.app_key.id
}