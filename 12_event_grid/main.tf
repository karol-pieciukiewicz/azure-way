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

module "event_grid_namespace" {
  source = "./modules/event-grid-namespace"

  name              = "${local.prefix}-egn"
  location          = var.location
  resource_group_id = azurerm_resource_group.rg.id
  is_zone_redundant = true

  tags = {
    environment = var.environment
  }
}

module "event_grid_topic" {
  source = "./modules/event-grid-topic"

  name         = "${local.prefix}-t1"
  namespace_id = module.event_grid_namespace.id

  event_retention_days = 7
}

module "event_grid_subscription" {
  source = "./modules/event-grid-subscription"

  name     = "${local.prefix}-s1"
  topic_id = module.event_grid_topic.id
}