variable "location" {
  type    = string
  default = "westeurope"
}

variable "fd_private_link_location" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type    = string
  default = "FrontDoor"
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_account_replication_type" {
  type    = string
  default = "LRS"
}

variable "storage_account_blob_container_name" {
  type    = string
  default = "mycontainer"
}

variable "waf_mode" {
  type    = string
  default = "Prevention"
}

variable "custom_domain_name" {
  type    = string
  default = "contoso.fabrikam.com"
}

variable "fd_name" {
  type  = string
  default = "Sample"

  description = "Front Door name for Profile, Origin, Route, WAF Policy"
}

variable "fd_sku_name" {
  type  = string
  default = "Premium_AzureFrontDoor"

  description = "Front Door Sku name - must be Premium for Private Link support"
}