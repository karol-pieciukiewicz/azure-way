variable "app_name" {
  default = "agentpool"
}

variable "location" {
  default = "westeurope"
}

variable "environment" {
  default = "prod"
}

variable "self_hosted_image_publisher" {
  default = "Azureway"
}

variable "self_hosted_image_offer" {
  default = "AgentPool"
}

variable "self_hosted_image_sku" {
  default = "Free"
}

variable "subscription-id" {
  description = "Subscription for service principal"
}

variable "spn-client-id" {
  description = "Client ID of the service principal"
}

variable "spn-client-secret" {
  description = "Secret for service principal"
}

variable "spn-tenant-id" {
  description = "Tenant ID for service principal"
}