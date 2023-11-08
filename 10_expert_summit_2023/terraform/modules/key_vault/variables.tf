variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource"
}

variable "name" {
  description = "Name of the Key Vault"
}

variable "soft_delete_retention_days" {
  default = "30"
}

variable "app_principal_id" {
  description = "Application principal ID"
}

variable "app_tenant_id" {
  description = "Application tenant ID"
}

variable "sku_name" {
  description = "SKU for Kev Vault instance"
  default     = "standard"
}

variable "pe_subnet_id" {
}

variable "vnet_id" {
  description = "Vnet ID where KV is created"
}

variable "ado_vnet_id" {
  description = "Vnet ID for Ado"
}