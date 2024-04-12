variable "name" {
  description = "Name of the event grid namespace"
}

variable "event_retention_days" {
  description = "Event retention for the namespace topic expressed in days. The property default value is 1 day. Min event retention duration value is 1 day and max event retention duration value is 7 day."
  default     = 1
}

variable "namespace_id" {
  description = "Event Grid Namespace id"
}