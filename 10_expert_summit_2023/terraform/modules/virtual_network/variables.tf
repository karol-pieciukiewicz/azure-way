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

variable "ado_vnet" {
  description = "VNET when Azure DevOps Agent is run"
}