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

resource "azurerm_user_assigned_identity" "ca_identity" {
  location            = var.location
  name                = "ca_identity"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "acrpull_mi" {
  scope                = azurerm_container_registry.cr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.ca_identity.principal_id
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

resource "azurerm_servicebus_namespace" "example" {
  name                = "${local.prefix}-servicebus-namespace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "example" {
  for_each = toset(var.queues)

  name         = each.value
  namespace_id = azurerm_servicebus_namespace.example.id

  enable_partitioning = false
}

output "acr_id" {
  value = azurerm_container_registry.cr.id
}

output "acr_name" {
  value = azurerm_container_registry.cr.login_server
}

output "servicebus_connection_string" {
  value = azurerm_servicebus_namespace.example.default_primary_connection_string
  sensitive = true
}

output "servicebus_namespace" {
  value = azurerm_servicebus_namespace.example.name
  sensitive = true
}

output "user_managed_idenity_resource_group" {
  value = azurerm_resource_group.rg.name
}