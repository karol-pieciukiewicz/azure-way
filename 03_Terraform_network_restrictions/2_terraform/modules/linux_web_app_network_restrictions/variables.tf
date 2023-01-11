variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource"
}

variable "name" {
  description = "The name which should be used for this Static Web App. Changing this forces a new Static Web App to be created."
}

variable "service_plan_id" {
  description = "Id of service plan"
}

variable "virtual_network_subnet_id" {
  description = "Id of virtual network subnet"
}

variable "key_vault_id" {
  description = "Optional keyvault Id for adding policy to Menaged Identity"
  default     = null
}

variable "tenant_id" {
  description = "Tenant ID"
}

variable "parent_subnet_id" {
  description = "Subnet id of APIM instance"
}

variable "ado_subnet_id" {
  description = "Subnet Id of Azure DevOps Agent"
}

variable "application_insights_instrumentation_key" {
  description = "Instrumanetion key for Application Insights"
}

variable "application_insights_connection_string" {
  description = "Connection string for Application Insights"
}

variable "dotnet_version" {
  description = "Dotnet version of application"
  default     = "7.0"
}