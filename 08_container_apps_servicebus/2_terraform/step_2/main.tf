locals {
  prefix     = "${random_pet.rg.id}-${var.environment}"
  prefixSafe = "${random_pet.rg.id}${var.environment}"
}

data "azurerm_client_config" "current" {}

resource "random_id" "random" {
  byte_length = 4
}

resource "random_pet" "rg" {
  length = 1
}

resource "azurerm_resource_group" "rg" {
  name     = local.prefix
  location = var.location
}

data "azurerm_user_assigned_identity" "ca_identity" {
  name                = var.user_managed_idenity_name
  resource_group_name = var.user_managed_idenity_resource_group
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${local.prefix}-la"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.la_sku
  retention_in_days   = var.la_retenction_days
}

module "virtual_network" {
  source = "./modules/virtual_network"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name                      = "${local.prefix}-vnet"
  address_space             = var.address_space
  subnet_address_prefix_map = var.subnet_address_prefix_map

  prefix = local.prefix
}

resource "azurerm_container_app_environment" "app_env" {
  name                       = "${local.prefix}-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id

  infrastructure_subnet_id = module.virtual_network.app_subnet_id
}

resource "azurerm_container_app" "sampleapi" {
  name                         = "${local.prefix}-app"
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.ca_identity.id]
  }

  registry {
    identity = data.azurerm_user_assigned_identity.ca_identity.id
    server   = var.acr_url
  }

  template {
    container {
      name   = "sampleapi"
      image  = "${var.acr_url}/${var.image_name}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "serviceBusConnectionString"
        secret_name = "service-bus-connection-string"
      }

      env {
        name  = "serviceBusQueue"
        value = var.servicebus_queueName
      }
    }

    custom_scale_rule {
      name             = "queue-scale-rule"
      custom_rule_type = "azure-servicebus"
      metadata = {
        queueName    = var.servicebus_queueName,
        namespace    = var.servicebus_namespace,
        messageCount = var.servicebus_messageScaleRule
      }
      authentication {
        secret_name       = "service-bus-connection-string"
        trigger_parameter = "connection"
      }
    }

    min_replicas = 0
    max_replicas = 25
  }

  secret {
    name  = "service-bus-connection-string"
    value = var.service_bus_connection_string
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}