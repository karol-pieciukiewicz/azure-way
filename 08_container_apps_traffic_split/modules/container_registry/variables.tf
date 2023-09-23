variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource"
}

variable "name" {
  description = "Name of the Container Registry"
}

variable "sku" {
  description = "SKU for Container Registry instance"
  default     = "Standard"
}

