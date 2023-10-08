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

variable "acr_sku" {
  default = "Basic"
  description = "SKU for Azure Container Registry"
}

variable "queues" {
  type = list(string)
  default = [ "test1", "test2", "test3", "test4" ]
}