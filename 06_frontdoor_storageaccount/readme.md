# [Azure Front Door as Secure Storage Blobs Access](https://azureway.cloud/azure-front-door-as-secure-storage-blobs-access/)

### Overview
- Azure Front Door is utilized for secure access to Azure Storage blobs.
- Features enabled by this setup:
  * Access Azure Storage Account using a custom domain with HTTPS.
  * Caching for faster responses, irrespective of request origin.
  * Disable direct connections to Azure Storage Account.
  * Utilize Microsoft backbone network for communication between Front Door and Storage Account.

### Required Terraform Resources
- To configure Azure Front Door, the following Terraform resources are needed:
  * azurerm_cdn_frontdoor_profile
  * azurerm_cdn_frontdoor_endpoint
  * azurerm_cdn_frontdoor_origin_group
  * azurerm_cdn_frontdoor_route
  * azurerm_cdn_frontdoor_custom_domain
  * azurerm_cdn_frontdoor_firewall_policy
  * azurerm_cdn_frontdoor_security_policy

### Terraform Script Execution
- Terraform sources have default values for parameters.
- Steps for execution include setting Azure credentials, initializing Terraform, and applying the configuration with auto-approval.

For detailed steps and Terraform sources, visit the [original article](https://azureway.cloud/azure-front-door-as-secure-storage-blobs-access/).
