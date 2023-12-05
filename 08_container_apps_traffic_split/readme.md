# [Azure Container Apps – Traffic Splitting [Part 4]](https://azureway.cloud/azure-container-apps-traffic-splitting-part-4/)

### Overview
- Discusses traffic splitting in Azure Container Apps, allowing multiple revisions of an application to share traffic.
- Enables specifying weight for each route to adjust traffic load, with the total weight summing to 100.

### Terraform Setup
- Details on configuring Azure Container Apps with Terraform for traffic splitting.
- Emphasizes setting the revision mode to 'Multiple' for traffic splitting.
  - [Source files on GitHub](https://azureway.cloud/azure-container-apps-traffic-splitting-part-4/).

### Revision and Traffic Weight Configuration
- Assigns unique values to the `revision_suffix` field in Terraform.
- Utilizes dynamic blocks to define traffic weights based on revision suffix.

### Execution Commands
- Provides Terraform commands for sample setup:
  - `terraform init`
  - `terraform apply -var-file=release_1.tfvars`
  - `terraform apply -var-file=release_2.tfvars`
- Explains the process of creating initial and subsequent revisions, and configuring traffic splitting.

For the complete series and detailed steps, visit the [original article](https://azureway.cloud/azure-container-apps-traffic-splitting-part-4/).
