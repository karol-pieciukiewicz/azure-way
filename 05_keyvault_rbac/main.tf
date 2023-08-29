terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.70.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  prefix     = "${var.environment}-${var.locationShortName}-${var.applicationName}"
  prefixSafe = "${var.environment}${var.locationShortName}${var.applicationName}"
}

data "azurerm_client_config" "current" {}

data "azurerm_user_assigned_identity" "kvReader" {
  name                = "ado-mi"
  resource_group_name = "ado"
}

resource "azurerm_resource_group" "example" {
  name     = local.prefix
  location = var.location
}

resource "azurerm_key_vault" "rbac_example" {
  name                        = "${local.prefix}-kv"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
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

resource "azurerm_key_vault_secret" "secret_1" {
  name         = "azurewaysecret"
  value        = "AzureWayRocks!"
  key_vault_id = azurerm_key_vault.rbac_example.id

  depends_on = [ azurerm_role_assignment.principal_rbac ]
}

resource "azurerm_role_assignment" "azurewaysecret_reader" {
  scope                = azurerm_key_vault_secret.secret_1.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_user_assigned_identity.kvReader.principal_id
}

