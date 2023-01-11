terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.36.0"
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
  prefix     = "${var.environment}-${var.locationShortName}-${var.applicationName}"
  prefixSafe = "${var.environment}${var.locationShortName}${var.applicationName}"
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

  lifecycle { ignore_changes = [tags] }
}

module "virtual_network" {
  source = "./modules/virtual_network"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name          = "${local.prefix}-vnet"
  address_space = ["10.0.0.0/16"]

  ado_vnet_id             = data.azurerm_virtual_network.adoAgentVnet.id
  ado_vnet_name           = data.azurerm_virtual_network.adoAgentVnet.name
  ado_vnet_resource_group = data.azurerm_virtual_network.adoAgentVnet.resource_group_name
  prefix                  = local.prefix
}

module "container_registry" {
  source = "./modules/container_registry"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "${local.prefixSafe}acr"

  sku = "Premium"

  vnet_id      = module.virtual_network.id
  ado_vnet_id  = data.azurerm_virtual_network.adoAgentVnet.id
  subnet_id    = module.virtual_network.app_subnet_id
  pe_subnet_id = module.virtual_network.pe_subnet_id

  agnet_pool_subnet_id = module.virtual_network.cr_agent_pool_subnet_id

  depends_on = [
    module.virtual_network
  ]
}

module "application_insights" {
  source = "./modules/application_insights"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  log_analytics_name          = "${local.prefix}-loganalytics"
  application_insights_name   = "${local.prefix}-ai"
  log_analytics_solution_name = "${local.prefix}-loganalytics-containerinsights"
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
  subnetIds        = [module.virtual_network.pe_subnet_id, module.virtual_network.app_subnet_id, data.azurerm_subnet.adoAgentSubnet.id]
  allowed_ips      = [var.administrator_ip]

}

module "azure_function_linux" {
  source = "./modules/azure_function_linux"

  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location

  params = {
    prefix                                   = local.prefix
    prefixSafe                               = local.prefixSafe
    service_plan_sku                         = var.service_plan_sku
    storage_account_replication_type         = "LRS"
    storage_account_tier                     = "Standard"
    log_analytics_sku                        = "PerGB2018"
    log_analytics_retenction_in_days         = 30
    keyVaultId                               = module.key_vault.id
    keyVaultName                             = module.key_vault.name
    tenantId                                 = module.current_user.tenant_id
    functionIdentityType                     = "SystemAssigned"
    application_insights_connection_string   = module.application_insights.connection_string
    application_insights_instrumentation_key = module.application_insights.instrumentation_key
    vnet_id                                  = module.virtual_network.id
    virtual_network_subnet_id                = module.virtual_network.app_subnet_id
    private_endpoint_subnet_id               = module.virtual_network.pe_subnet_id
    parent_subnet_id                         = module.virtual_network.integration_subnet_id
    ado_subnet_id                            = data.azurerm_subnet.adoAgentSubnet.id
    application_insights_name                = module.application_insights.name
    dotnet_version                           = "7.0"
  }
}

module "web_app_with_db" {
  source = "./modules/linux_web_app_network_restrictions"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "${local.prefix}-api-sql-webapp"

  virtual_network_subnet_id = module.virtual_network.app_subnet_id
  service_plan_id           = module.azure_function_linux.service_plan_id

  key_vault_id = module.key_vault.id
  tenant_id    = module.current_user.tenant_id

  parent_subnet_id = module.virtual_network.integration_subnet_id
  ado_subnet_id    = data.azurerm_subnet.adoAgentSubnet.id

  application_insights_connection_string   = module.application_insights.connection_string
  application_insights_instrumentation_key = module.application_insights.instrumentation_key
}

module "sample_dotnet_docker" {
  source = "./modules/linux_web_app_docker"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "${local.prefix}-docker-webapp"

  virtual_network_subnet_id = module.virtual_network.app_subnet_id
  service_plan_id           = module.azure_function_linux.service_plan_id

  key_vault_id = module.key_vault.id
  tenant_id    = module.current_user.tenant_id

  parent_subnet_id = module.virtual_network.integration_subnet_id
  ado_subnet_id    = data.azurerm_subnet.adoAgentSubnet.id

  acr_server_url = module.container_registry.url
  acr_id         = module.container_registry.id

  docker_image_name = "devweunetworkacr.azurecr.io/azureway/sampleapi"

  application_insights_connection_string   = module.application_insights.connection_string
  application_insights_instrumentation_key = module.application_insights.instrumentation_key
}

module "apim" {
  source = "./modules/application_management"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "${local.prefix}-apim"

  publisher_email = var.administrator_email
  publisher_name  = var.administrator_name

  virtual_network_type = "External"
  subnet_id            = module.virtual_network.integration_subnet_id

  sku_name = "Developer_1"

  function_key_id = module.azure_function_linux.app_key_secret_id

  key_vault_id = module.key_vault.id
  tenant_id    = module.current_user.tenant_id

  add_policy_to_azure_function_apim = var.add_policy_to_azure_function_apim

  depends_on = [
    module.key_vault
  ]
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
}