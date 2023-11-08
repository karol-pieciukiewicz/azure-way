variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource"
}

variable "name" {
  description = "The name which should be used for this Static Web App. Changing this forces a new Static Web App to be created."
}

variable "virtual_network_subnet_id" {
  description = "Id of virtual network subnet"
}

variable "key_vault_id" {
  
}

variable "key_vault_name" {
  description = "Keyvault name for secret"
}

variable "key_vault_secret_name" {
  description = "Secret name from Keyvault"
}

variable "tenant_id" {
  description = "Tenant ID"
}

variable "dotnet_version" {
  description = "Dotnet version of application"
  default     = "7.0"
}

variable "service_plan_sku" {
  description = "SKU for App Service Plan"
}

variable "app_vnet_id" {
  
}

variable "ado_vnet_id" {
  
}

variable "pe_subnet_id" {
  
}