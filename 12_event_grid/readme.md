# [Azure Event Grid Namespace - Terraform Setup](https://azureway.cloud/azure-event-grid-namespace-terraform-setup/)

## Overview

This repository contains Terraform modules for creating an Azure Event Grid Namespace, Topic, and Subscription using the AzAPI provider. The modules provided here are part of a series dedicated to Azure Event Grid and demonstrate initial and straightforward setups.

### Components

- **Event Grid Namespace:** Utilizes a public endpoint, system-assigned identity, and operates under the Standard SKU.
- **Event Grid Topic:** Configures with CloudEventSchemaV1_0 as the input schema.
- **Event Grid Subscription:** Uses Queue delivery mode and the CloudEventSchemaV1_0 event delivery schema.
