# [Azure Container Registry – Repository Permissions](https://azureway.cloud/azure-container-registry-repository-permissions/)

### Overview
- **Repository-Scoped Tokens**: For detailed repository access management.
- **RBAC vs. Tokens**: More granular control than broad Role-Based Access Control.

### Use Cases
- IoT device-specific access.
- Access for external organizations.
- Diverse permissions for different user groups.

### Terraform Components
- **Azure Key Vault**: Secures token storage.
- **Azure Container Registry**: Site for token creation.
- **Scope Map**: Defines access levels.
- **Token & Token Password**: Access resources with expiration settings.

For detailed setup and additional insights, visit the [full article](https://azureway.cloud/azure-container-registry-repository-permissions/).
