locals {
  prefix     = "${random_pet.rg.id}-${var.environment}"
  prefixSafe = "${random_pet.rg.id}${var.environment}"
}

data "azurerm_client_config" "current" {}

resource "random_pet" "rg" {
  length = 1
}

resource "azurerm_resource_group" "rg" {
  name     = local.prefix
  location = var.location
}

resource "azurerm_container_registry" "cr" {
  name                = "${local.prefixSafe}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  sku                           = var.acr_sku
  admin_enabled                 = true
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_container_registry_task" "cleaner" {
  name                  = "image-pure-task"
  container_registry_id = azurerm_container_registry.cr.id

  platform {
    os = "Linux"
  }

  encoded_step {
    task_content = <<EOF
      version: v1.1.0
      steps: 
        - cmd: mcr.microsoft.com/acr/acr-cli:0.5 ${var.acr_clean_cmd}
          disableWorkingDirectoryOverride: true
          timeout: 3600
      EOF
  }
  agent_setting {
    cpu = 2
  }

  timer_trigger {
    name     = "Clean images per day"
    enabled  = true
    schedule = var.clean_schedule_cron
  }

}