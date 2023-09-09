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