resource "azapi_resource" "topic" {
  type      = "Microsoft.EventGrid/namespaces/topics@2023-12-15-preview"
  name      = var.name
  parent_id = var.namespace_id

  body = jsonencode({
    properties = {
      eventRetentionInDays = var.event_retention_days
      inputSchema          = "CloudEventSchemaV1_0"
      publisherType        = "Custom"
    }
  })
}