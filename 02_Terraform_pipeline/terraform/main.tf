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

# get current user data
module "current_user" {
  source = "./modules/current_user"
}

resource "azurerm_resource_group" "rg" {
  name     = local.prefix
  location = var.location

  lifecycle { ignore_changes = [tags] }
}