# [Azure Container Apps – Creating using Terraform [Part 1]](https://azureway.cloud/azure-container-apps-creating-using-terraform-part-1/)

### Overview
- Discusses creating Azure Container Apps using Terraform, a process that was challenging due to the use of AzApi but has been simplified with AzureRM provider resources.

### Key Components Created by the Terraform Script
- Azure Container App Environment integrated with a Virtual Network.
- Container App and Ingress for internet traffic routing.
- Azure Virtual Network, Azure Container Registry, and Azure Log Analytics workspace.
- User Managed Identity for Container Registry authentication.

### Steps for Using an Image from Azure Container Registry (ACR)
- Create a user-managed identity.
- Assign AcrPull permission to the identity.
- Add this identity to the Container App and configure the registry to use it.

### Importing a Sample Image from Public Microsoft Azure Container Registry to Private ACR
- Uses a local-exec provisioner in Terraform.
- Requires Azure login for executing the script.

For detailed steps and source files, visit the [original article](https://azureway.cloud/azure-container-apps-creating-using-terraform-part-1/).
