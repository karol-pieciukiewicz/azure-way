variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource"
}

variable "name" {
  description = "Name of the Container Registry"
}

variable "vnet_id" {
  description = "Vnet ID where KV is created"
}

variable "ado_vnet_id" {
  description = "Vnet ID for Ado"
}

variable "subnet_id" {
  description = "Id of integrated subnet"
}

variable "pe_subnet_id" {
  description = "Id of subnet for private endpoint"
}

variable "agnet_pool_subnet_id" {
  description = "Subnet id of agent pool for ACR"
}

variable "sku" {
  description = "SKU for Container Registry instance"
  default     = "Standard"
}

variable "agent_pool_tier" {
  description = "Tier for Azure container registry agent pool"
  default     = "S1"
}
