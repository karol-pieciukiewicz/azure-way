resource "azurerm_linux_web_app" "app" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  https_only                = true
  virtual_network_subnet_id = var.virtual_network_subnet_id

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.application_insights_instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.application_insights_connection_string
  }

  site_config {
    application_stack {
      dotnet_version = var.dotnet_version
    }

    ip_restriction {
      virtual_network_subnet_id = var.parent_subnet_id
    }
    ip_restriction {
      virtual_network_subnet_id = var.ado_subnet_id
    }

    vnet_route_all_enabled = true
    always_on              = true
  }

  lifecycle { ignore_changes = [tags] }
}

module "web_app_access_policy" {
  source = "../../modules/key_vault_access_policy"

  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_linux_web_app.app.identity[0].principal_id

  key_permissions         = []
  secret_permissions      = ["List", "Get"]
  certificate_permissions = []
  storage_permissions     = []
}

output "principal_id" {
  value = azurerm_linux_web_app.app.identity[0].principal_id
}
