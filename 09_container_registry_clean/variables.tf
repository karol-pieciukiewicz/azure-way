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
  default     = "Standard"
  description = "SKU for Azure Container Registry"
}

variable "clean_schedule_cron" {
  default     = "30 10 * * *"
  description = "NCronTab expression for running clean task"
}

variable "acr_clean_cmd" {
  default     = "purge --filter 'messagereader:.*' --keep 5 --ago 0d"
  description = "Command for cleaning images in the registry"
}