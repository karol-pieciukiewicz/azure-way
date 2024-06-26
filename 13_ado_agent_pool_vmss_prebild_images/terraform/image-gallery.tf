locals {
  prefix    = "${var.app_name}-agentpool"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "automation_resource_group" {
  name     = "${local.prefix}-rg"
  location = var.location
}

check "community_image_validation" {
  assert {
    condition = can(var.shared_images[var.community_image])
    error_message = "The community image ${var.community_image} is not supported. Supported values are: ${join(", ", keys(var.shared_images))}"
  }
}

module "scale_set"{
  source = "./virtual_machine_scale_set"

  resource_group_name = azurerm_resource_group.automation_resource_group.name
  location = azurerm_resource_group.automation_resource_group.location

  sku = var.sku
  
  gallery_image_id = "${var.shared_images[var.community_image]}${var.community_image_version}"
}
