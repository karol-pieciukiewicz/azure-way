variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource"
}

variable "name" {
  description = "Name of the Key Vault"
}

variable "publisher_name" {
  description = "The name of publisher/company."
}

variable "publisher_email" {
  description = "The email of publisher/company."
}

variable "virtual_network_type" {
  description = "The type of virtual network you want to use, valid values include: None, External, Internal"
}

variable "subnet_id" {
  description = "The id of the subnet that will be used for the API Management."
}

variable "sku_name" {
  description = "sku_name is a string consisting of two parts separated by an underscore(_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1)."
}

variable "function_key_id" {
  description = "Access key for azure function"
}

variable "key_vault_id" {
  description = "Id of the used KeyVault"
}

variable "tenant_id" {
  description = "Tenant Id to which KeyVault belongs"
}

variable "add_policy_to_azure_function_apim" {
  description = "Indicates if policy to Azure function API in APIM will be added. Should be run, after Azure Function deployment"
}