output "keyvault_uri" {
  value = azurerm_key_vault.keyvault.vault_uri
}

output "id" {
  value = azurerm_key_vault.keyvault.id
}

output "name" {
  value = azurerm_key_vault.keyvault.name
}

output "secret_name"{
  value = azurerm_key_vault_secret.secret_1.name
}
