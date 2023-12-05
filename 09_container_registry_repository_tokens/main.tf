locals {
  prefix     = "${random_pet.rg.id}-${var.environment}"
  prefixSafe = "${random_pet.rg.id}${var.environment}"
}

data "azurerm_client_config" "current" {}

resource "random_pet" "rg" {
  length = 1
}

resource "azurerm_resource_group" "rg" {
  name     = local.prefix
  location = var.location
}

resource "time_offset" "key1_year" {
  offset_days = 365

  triggers = {
    "key_version" = var.key1_version
  }
}

resource "time_offset" "key2_year" {
  offset_days = 365

  triggers = {
    "key_version" = var.key2_version
  }
}


resource "azurerm_key_vault" "rbac" {
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
  scope                = azurerm_key_vault.rbac.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_container_registry" "cr" {
  name                = "${local.prefixSafe}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  sku                           = var.acr_sku
  admin_enabled                 = true
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_container_registry_scope_map" "maps" {
  for_each = var.scope_maps

  name                    = "${each.value.name}-scope-map"
  container_registry_name = azurerm_container_registry.cr.name
  resource_group_name     = azurerm_resource_group.rg.name
  actions                 = each.value.actions
}

resource "azurerm_container_registry_token" "tokens" {
  for_each = var.scope_maps

  name                    = "${each.value.name}-token"
  container_registry_name = azurerm_container_registry.cr.name
  resource_group_name     = azurerm_resource_group.rg.name
  scope_map_id            = azurerm_container_registry_scope_map.maps[each.key].id
}

resource "azurerm_container_registry_token_password" "keys" {
  for_each = var.scope_maps

  container_registry_token_id = azurerm_container_registry_token.tokens[each.key].id

  password1 {
    expiry = time_offset.key1_year.rfc3339
  }
  password2 {
    expiry = time_offset.key2_year.rfc3339
  }
}

resource "azurerm_key_vault_secret" "secret_1" {
  for_each = var.scope_maps

  name         = "${each.value.name}-key_1"
  value        = azurerm_container_registry_token_password.keys[each.key].password1[0].value
  key_vault_id = azurerm_key_vault.rbac.id

  depends_on = [ azurerm_role_assignment.principal_rbac ]
}

resource "azurerm_key_vault_secret" "secret_2" {
  for_each = var.scope_maps

  name         = "${each.value.name}-key_2"
  value        = azurerm_container_registry_token_password.keys[each.key].password2[0].value
  key_vault_id = azurerm_key_vault.rbac.id

  depends_on = [ azurerm_role_assignment.principal_rbac ]
}