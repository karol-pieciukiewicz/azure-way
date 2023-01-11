variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource"
}

variable "log_analytics_name" {
  description = "Name of the log analytics"
}

variable "application_insights_name" {
  description = "Name of the application insights"
}

variable "retention_days" {
  default = 30
}

variable "sku" {
  default = "PerGB2018"
}

variable "application_type" {
  default = "web"
}

variable "log_analytics_solution_name" {
  description = "Name of the log analytics solution"
}