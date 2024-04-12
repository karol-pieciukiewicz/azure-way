variable "name" {
  description = "Name of the event grid namespace"
}

variable "location" {
  description = "Location of the event grid namespace"
}

variable "resource_group_id" {
  description = "Resource group id where the event grid namespace will be created"
}

variable "tags" {
  description = "Tags for event grid namespace"
}

variable "is_zone_redundant" {
  description = "Is event grid namespace zone redundant?"
  default     = false
}

variable "instances_count" {
  description = "Specifies the number of Throughput Units that defines the capacity for the namespace"
  default     = 1
}