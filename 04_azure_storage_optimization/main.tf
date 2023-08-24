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


resource "azurerm_resource_group" "example" {
  name     = local.prefix
  location = var.location
}

resource "azurerm_storage_account" "logs" {
  name                = "${local.prefixSafe}sa"
  resource_group_name = azurerm_resource_group.example.name

  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "BlobStorage"

  blob_properties {
    last_access_time_enabled = true
  }
}

resource "azurerm_storage_management_policy" "example" {
  storage_account_id = azurerm_storage_account.logs.id

  rule {
    name    = "logs_rule"
    enabled = true
    filters {
      prefix_match = ["logs"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_last_access_time_greater_than    = 1
        auto_tier_to_hot_from_cool_enabled                             = true
        tier_to_archive_after_days_since_last_access_time_greater_than = 90
        delete_after_days_since_last_access_time_greater_than          = 180
      }
    }
  }
}