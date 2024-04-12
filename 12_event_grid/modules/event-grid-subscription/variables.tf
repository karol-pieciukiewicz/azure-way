variable "name" {
  description = "Name of the event grid namespace"
}

variable "topic_id" {
  description = "Event grid topic id"
}

variable "event_time_to_live" {
  description = "Time span duration in ISO 8601 format that determines how long messages are available to the subscription from the time the message was published."
  default     = "P7D"
}

variable "max_delivery_count" {
  description = "The maximum delivery count of the events."
  default = 7
}

variable "lock_duration_seconds" {
  description = "Maximum period in seconds in which once the message is in received (by the client) state and waiting to be accepted, released or rejected. If this time elapsed after a message has been received by the client and not transitioned into accepted (not processed), released or rejected, the message is available for redelivery. This is an optional field, where default is 60 seconds, minimum is 60 seconds and maximum is 300 seconds."
  default = 60
}

