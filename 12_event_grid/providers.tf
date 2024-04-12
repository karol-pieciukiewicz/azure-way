# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.96"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 1.12.1"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}

}

provider "azapi" {
}