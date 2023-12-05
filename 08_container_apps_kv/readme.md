# [Azure Container Apps – Secrets [Part 5]](https://azureway.cloud/azure-container-apps-secrets-part-5/)

### Introduction
- Focuses on loading secrets into Azure Container Apps using Azure KeyVault.
- Addresses the challenge of integrating Terraform and Key Vault for adding secrets.

### Terraform Setup
- Covers the creation of Azure Key Vault and Container Apps using Terraform.
- Includes a sample application demonstrating secret usage.
- Utilizes RBAC for Key Vault access and role assignments.
  - [Source files on GitHub](https://azureway.cloud/azure-container-apps-secrets-part-5/).

### Building the Sample Application
- Guide to construct an API application image that retrieves secrets.
- Involves Azure CLI commands to build and configure the application.

### Terraform Script Execution
- Detailed instructions for executing Terraform script.
- Outputs crucial variables like Key Vault secret URL, name, identity, and environment variable name for secrets.

### Adding Secrets via Azure CLI
- Two-step process to add secrets to Container Apps using Azure CLI:
  1. Add the secret using Key Vault references.
  2. Create an environment variable linked to the secret.

### Conclusion
- Offers insights into managing secrets in Azure Container Apps effectively, despite current Terraform limitations.

For more details and the complete series, visit the [original article](https://azureway.cloud/azure-container-apps-secrets-part-5/).
