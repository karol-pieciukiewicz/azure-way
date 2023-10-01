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

resource "azurerm_user_assigned_identity" "ca_identity" {
  location            = var.location
  name                = "ca_identity"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "acrpull_mi" {
  scope                = module.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.ca_identity.principal_id
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

module "container_registry" {
  source = "./modules/container_registry"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "${local.prefixSafe}acr"
}

resource "azurerm_key_vault" "rbac_example" {
  name                        = "${local.prefix}-kv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  enable_rbac_authorization = true
  sku_name                  = "standard"
}

resource "azurerm_role_assignment" "principal_rbac" {
  scope                = azurerm_key_vault.rbac_example.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "azurewaysecret_reader" {
  scope                = azurerm_key_vault_secret.secret_1.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.ca_identity.principal_id
}

resource "azurerm_container_app_environment" "app_env" {
  name                       = "${local.prefix}-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id

  infrastructure_subnet_id = module.virtual_network.app_subnet_id
}

resource "azurerm_key_vault_secret" "secret_1" {
  name         = "azurewaysecret"
  value        = "AzureWayRocks!"
  key_vault_id = azurerm_key_vault.rbac_example.id

  depends_on = [ azurerm_role_assignment.principal_rbac ]
}

resource "azurerm_container_app" "sampleapi" {
  name                         = "${local.prefix}-app"
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ca_identity.id]
  }

  registry {
    identity = azurerm_user_assigned_identity.ca_identity.id
    server   = module.container_registry.url
  }

  template {
    container {
      name   = "sampleapi"
      image  = "${module.container_registry.url}/${var.image_name}"
      cpu    = 0.25
      memory = "0.5Gi" 
    }

    min_replicas = 0
    max_replicas = 5

  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80

    traffic_weight {
      latest_revision = true
      percentage = 100
    }
  }

  lifecycle {
    ignore_changes = [ secret, template[0].container[0].env ]
  }
}

output "keyVaultSecretUrl" {
  value = "${azurerm_key_vault.rbac_example.vault_uri}secrets/${azurerm_key_vault_secret.secret_1.name}"
}

output "keyVaultSecretName" {
  value = "${azurerm_key_vault_secret.secret_1.name}"
}

output "keyVaultIdentity" {
  value = azurerm_user_assigned_identity.ca_identity.id
}

output "envSecretName" {
  value = "ResponseText"
}