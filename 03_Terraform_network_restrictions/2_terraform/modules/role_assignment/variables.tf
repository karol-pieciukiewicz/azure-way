variable "principal_id" {
  description = "Princiapal for role assignment"
}

variable "role_definition_name" {
  description = "Role definition name"
}

variable "scope" {
  description = "Scope of the role assignmnent"
}

variable "skip_service_principal_aad_check" {
  description = "Flag indicates skip service principal aad check"
  default     = false
}