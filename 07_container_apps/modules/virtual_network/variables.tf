variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource"
}

variable "name" {
  description = "Name of the AKS"
}

variable "address_space" {
  description = "Vnet address space"
}

variable "prefix" {
  description = "Prefix for subnet name"
}

variable "subnet_address_prefix_map" {
  type = map(list(string))
}