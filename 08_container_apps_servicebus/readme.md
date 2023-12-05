# [Azure Container Apps – Service Bus [Part 6]](https://azureway.cloud/azure-container-apps-service-bus-part-6/)

### Overview
- Discusses integrating Azure Container Apps with Azure Service Bus, highlighting its ease and performance impact.
- Provides a guide on setting up this integration, including performance test results.

### Integration Steps
- Details on configuring Azure Container Apps with Terraform for integration with Azure Service Bus.
- Includes creating a secret for the Azure Service Bus connection string and setting up custom scaling rules.
  - [Source files on GitHub](https://azureway.cloud/azure-container-apps-service-bus-part-6/).

### Performance Testing
- Conducted tests with varying message counts, demonstrating efficient processing and scaling capabilities.
- Example: Processed 12,000 messages in 60 seconds with a delay of 150 milliseconds per message using 25 replicas.

### Testing Procedure
- Steps to replicate the test are provided, including Terraform script execution and Docker image creation.

### User Managed Identity
- Usage of User Managed Identity in Terraform scripts for image retrieval from Azure Container Registry.

### Summary
- Shows the potential of Azure Container Apps when integrated with Azure Service Bus, especially in handling high message volumes and efficient scaling.

For complete details, visit the [original article](https://azureway.cloud/azure-container-apps-service-bus-part-6/).
