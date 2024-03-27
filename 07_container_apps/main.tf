locals {
  prefix     = "${random_pet.rg.id}-${var.environment}"
  prefixSafe = "${random_pet.rg.id}${var.environment}"

  image_name = "containerapps-helloworld:latest"
  redis_sample_app_image = "sample-service-redis:latest"
}

data "azurerm_client_config" "current" {}

resource "random_id" "random" {
  byte_length = 4
}

resource "random_pet" "rg" {
  length = 1
}

resource "azurerm_resource_group" "rg" {
  name     = local.prefix
  location = var.location
}

resource "azurerm_user_assigned_identity" "ca_identity" {
  location            = var.location
  name                = "ca_identity"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "acrpull_mi" {
  scope                = module.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.ca_identity.principal_id
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${local.prefix}-la"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.la_sku
  retention_in_days   = var.la_retenction_days
}

module "virtual_network" {
  source = "./modules/virtual_network"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name                      = "${local.prefix}-vnet"
  address_space             = var.address_space
  subnet_address_prefix_map = var.subnet_address_prefix_map

  prefix = local.prefix
}

module "container_registry" {
  source = "./modules/container_registry"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  name = "${local.prefixSafe}acr"
}

resource "azurerm_container_app_environment" "app_env" {
  name                       = "${local.prefix}-environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id

  infrastructure_subnet_id = module.virtual_network.app_subnet_id

  workload_profile {
    name = "test-1"
    workload_profile_type = "D4"
    maximum_count = 1
    minimum_count = 1
  }
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [module.container_registry]

  create_duration = "60s"
}

resource "null_resource" "acr_import" {
  provisioner "local-exec" {
    command = <<-EOT
        az acr import \
            --name ${module.container_registry.name} \
            --source mcr.microsoft.com/azuredocs/${local.image_name} \
            --image ${local.image_name}
      EOT
  }

  depends_on = [ time_sleep.wait_60_seconds ]
}

resource "null_resource" "redis_acr_import" {
  provisioner "local-exec" {
    command = <<-EOT
        az acr import \
            --name ${module.container_registry.name} \
            --source mcr.microsoft.com/k8se/samples/${local.redis_sample_app_image} \
            --image ${local.redis_sample_app_image}
      EOT
  }

  depends_on = [ time_sleep.wait_60_seconds ]
}


resource "azurerm_container_app" "sampleapi" {
  name                         = "${local.prefix}-app"
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ca_identity.id]
  }

  registry {
    identity = azurerm_user_assigned_identity.ca_identity.id
    server   = module.container_registry.url
  }

  template {
    container {
      name   = "sampleapi"
      image  = "${module.container_registry.url}/${local.image_name}"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    min_replicas = 0
    max_replicas = 5

  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
   
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  depends_on = [null_resource.acr_import]
}

resource "azurerm_container_app" "sampleapi_dedicated" {
  name                         = "${local.prefix}-dedicated-app"
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "test-1"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ca_identity.id]
  }

  registry {
    identity = azurerm_user_assigned_identity.ca_identity.id
    server   = module.container_registry.url
  }

  template {
    container {
      name   = "sampleapi"
      image  = "${module.container_registry.url}/${local.image_name}"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    min_replicas = 0
    max_replicas = 5

  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
   
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  depends_on = [null_resource.acr_import]
}


resource "azurerm_container_app" "sampleredis_dedicated" {
  name                         = "${local.prefix}-redis-app"
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "test-1"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ca_identity.id]
  }

  registry {
    identity = azurerm_user_assigned_identity.ca_identity.id
    server   = module.container_registry.url
  }

  template {
    container {
      name   = "sampleredisapp"
      image  = "${module.container_registry.url}/${local.redis_sample_app_image}"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    min_replicas = 0
    max_replicas = 5

  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8080
   
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  depends_on = [null_resource.redis_acr_import]
}