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

variable "scope_maps" {
  type = map(object({
    repo_name = string,
    actions   = list(string)
  }))

  default = {
    v1 = {
      repo_name = "messagereader",
      actions = [
        "repositories/messagereader/content/read"
      ]
    }
    v2 = {
      repo_name = "adoagent",
      actions = [
        "repositories/ado/content/read",
        "repositories/ado/content/write"
      ]
    }
  }
}

variable "key1_version" {
  default = 1
}

variable "key2_version" {
  default = 1
}