resource "azapi_resource" "event_grid_namespace" {
  type = "Microsoft.EventGrid/namespaces@2023-12-15-preview"

  name      = var.name
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties = {
      isZoneRedundant     = var.is_zone_redundant
      publicNetworkAccess = "Enabled"
    }
    sku = {
      capacity = var.instances_count
      name     = "Standard"
    }
  })
}





