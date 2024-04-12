resource "azapi_resource" "event_grid_subscription" {
  type      = "Microsoft.EventGrid/namespaces/topics/eventSubscriptions@2023-12-15-preview"
  name      = var.name
  parent_id = var.topic_id

  body = jsonencode({
    properties = {
      deliveryConfiguration = {
        deliveryMode = "Queue"
        queue = {
          eventTimeToLive              = var.event_time_to_live
          maxDeliveryCount             = var.max_delivery_count
          receiveLockDurationInSeconds = var.lock_duration_seconds
        }
      }
      eventDeliverySchema = "CloudEventSchemaV1_0"
    }
  })
}