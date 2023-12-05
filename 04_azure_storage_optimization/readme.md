# [Azure Storage Account – Making it Cost-Effective](https://azureway.cloud/azure-storage-account-making-it-cost-effective/)

### Overview
- Discusses strategies for cost-effective management of Azure Storage Accounts.
- Emphasizes the importance of selecting the appropriate storage tier based on cost and usage needs.

### Storage Tier Pricing
- Pricing for 1000 GB in different tiers:
  * Hot: 21 USD
  * Cool: 15 USD
  * Cold: 3.6 USD
  * Archive: 0.99 USD

### Lifecycle Management
- Utilizes lifecycle management to move blobs between tiers, optimizing costs.
- Rules can be based on various factors like last modification, last access, creation, and last tier change.

### Terraform Script for Lifecycle Management
- Provides a Terraform script to automate the lifecycle management process.
- Current azurerm provider version (3.70.0) lacks transition from/into Cold tier, but this can be managed in the Azure portal.

For detailed instructions and Terraform script, visit the [original article](https://azureway.cloud/azure-storage-account-making-it-cost-effective/).
