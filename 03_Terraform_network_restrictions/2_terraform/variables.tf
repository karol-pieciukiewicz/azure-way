variable "environment" {
  description = "Name of the environment"
}

variable "applicationName" {
  description = "Name of the application"
}

variable "location" {
  description = "Primary location of the services"
}

variable "locationShortName" {
  description = "Short name of the location"
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

variable "administrator_ip" {
  description = "IP of the system administrator"
}

variable "administrator_email" {
  description = "Email of the system administrator"
}

variable "administrator_object_id" {
  description = "Object ID of the system administrator"
}

variable "administrator_name" {
  description = "Name of the system administrator"
}

variable "add_policy_to_azure_function_apim" {
  description = "Indicates if policy to Azure function API in APIM will be added. Should be run, after Azure Function deployment"
}

variable "ado_resource_group" {
  description = "Name of the reousrce group, where Azure DevOps Self-hosted agent is deployed"
}
variable "ado_virtual_network_name" {
  description = "Name of the virtual network, where Azure DevOps Self-hosted agent is deployed"
}
variable "ado_subnet_name" {
  description = "Name of the subnet, where Azure DevOps Self-hosted agent is deployed"
}
variable "service_plan_sku" {
  description = "SKU for service plan used in Azure Function, App Service, App Service with docker"
}

