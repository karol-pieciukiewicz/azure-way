variable "environment" {
  description = "Name of the environment"
  default     = "test"
}

variable "applicationName" {
  description = "Name of the application"
  default     = "container-app"
}

variable "location" {
  description = "Primary location of the services"
  default     = "westeurope"
}

variable "address_space" {
  type    = list(string)
  default = ["40.0.0.0/16"]
}

variable "subnet_address_prefix_map" {
  type = map(list(string))
  default = {
    "app" = ["40.0.0.0/23"]
  }
}

variable "la_sku" {
  type    = string
  default = "PerGB2018"
}

variable "la_retenction_days" {
  type    = number
  default = 30
}

variable "servicebus_queueName" {
  description = "Name of the service bus queue for Container App scalling"
}
variable "servicebus_namespace" {
  description = "Name of the service bus namespace for Container App scalling"
}
variable "servicebus_messageScaleRule" {
  description = "Indicator on how many messages Container App scale"
}
variable "service_bus_connection_string" {
  description = "Connection string for service bus"
}

variable "acr_url" {
  description = "URL of Azure Container Rerigstry for sample images"
}
variable "image_name" {
  description = "Image name of sample Azure Service bus consumer"
}

variable "user_managed_idenity_resource_group" {
  description = "Resource group name storing User Managed Idenity for Azure Container Registry access"
}

variable "user_managed_idenity_name" {
  description = "Name of the User Managed Idenity for Azure Container Registry access"
  default     = "ca_identity"
}