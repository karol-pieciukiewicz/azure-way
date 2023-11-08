terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.78.0"
    }
  }

  backend "azurerm" {
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription-id
  client_id       = var.spn-client-id
  client_secret   = var.spn-client-secret
  tenant_id       = var.spn-tenant-id
}

locals {
  prefix     = "${random_pet.rg.id}-${var.environment}"
  prefixSafe = "${random_pet.rg.id}${var.environment}"
}

resource "random_pet" "rg" {
  length = 1
}

data "azurerm_subnet" "adoAgentSubnet" {
  name                 = var.ado_subnet_name
  virtual_network_name = var.ado_virtual_network_name
  resource_group_name  = var.ado_resource_group
}

data "azurerm_virtual_network" "adoAgentVnet" {
  name                = var.ado_virtual_network_name
  resource_group_name = var.ado_resource_group
}

# get current user data
module "current_user" {
  source = "./modules/current_user"
}

resource "azurerm_resource_group" "rg" {
  name     = local.prefix
  location = var.location
}

module "virtual_network" {
  source = "./modules/virtual_network"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name          = "${local.prefix}-vnet"
  address_space = ["10.0.0.0/16"]

  ado_vnet = data.azurerm_virtual_network.adoAgentVnet
  prefix   = local.prefix
}

module "key_vault" {
  source = "./modules/key_vault"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name             = "${local.prefix}-kv"

  app_principal_id = module.current_user.object_id
  app_tenant_id    = module.current_user.tenant_id

  vnet_id          = module.virtual_network.id
  ado_vnet_id      = data.azurerm_virtual_network.adoAgentVnet.id

  pe_subnet_id        = module.virtual_network.pe_subnet_id
}

module "web_app_with_db" {
  source = "./modules/linux_web_app_network_restrictions"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "${local.prefix}-api-sql-webapp"

  virtual_network_subnet_id = module.virtual_network.app_subnet_id
  service_plan_sku          = var.service_plan_sku

  key_vault_id = module.key_vault.id
  key_vault_name = module.key_vault.name
  key_vault_secret_name = module.key_vault.secret_name
  tenant_id    = module.current_user.tenant_id

  pe_subnet_id = module.virtual_network.pe_subnet_id
  
  app_vnet_id = data.azurerm_virtual_network.adoAgentVnet.id
  ado_vnet_id = module.virtual_network.id
}

module "apim" {
  source = "./modules/api_management"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "${local.prefix}-apim"

  publisher_email = var.administrator_email
  publisher_name  = var.administrator_name

  virtual_network_type = "External"
  subnet_id            = module.virtual_network.integration_subnet_id

  sku_name = "Developer_1"

  key_vault_id = module.key_vault.id
  tenant_id    = module.current_user.tenant_id
}

module "sql_server" {
  source = "./modules/sql_server"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "${local.prefix}-sql-server"

  admin_object_id = var.administrator_object_id
  admin_username  = var.administrator_name

  pe_subnet_id = module.virtual_network.pe_subnet_id
  vnet_id      = module.virtual_network.id
  ado_vnet_id  = data.azurerm_virtual_network.adoAgentVnet.id

  administrator_ip = var.administrator_ip
}