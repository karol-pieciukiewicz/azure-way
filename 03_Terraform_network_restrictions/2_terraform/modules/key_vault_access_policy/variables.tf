variable "key_vault_id" {
  description = "KeyVault instance ID"
}

variable "tenant_id" {
  description = "Tenant ID for realted object"
}

variable "object_id" {
  description = "Object ID for realted object"
}

variable "key_permissions" {
  description = "Permissions for keys"
}

variable "secret_permissions" {
  description = "Permissions for secrets"
}

variable "certificate_permissions" {
  description = "Permission for certificates"
}

variable "storage_permissions" {
  description = "Permission for storage"
}