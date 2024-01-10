locals {
  prefix    = "${var.app_name}-automation-${var.environment}"
  imagePath = "../runner-images-main/images/ubuntu/templates/ubuntu-22.04.pkr.hcl"
}


data "azurerm_client_config" "current" {}

resource "azurerm_shared_image_gallery" "imageGallery" {
  name                = "gal_${var.app_name}_${var.environment}"
  resource_group_name = azurerm_resource_group.automation_resource_group.name
  location            = azurerm_resource_group.automation_resource_group.location
}

resource "azurerm_shared_image" "image" {
  name                = "ubuntu2204-agent-poll"
  gallery_name        = azurerm_shared_image_gallery.imageGallery.name
  resource_group_name = azurerm_resource_group.automation_resource_group.name
  location            = azurerm_resource_group.automation_resource_group.location
  os_type             = "Linux"

  identifier {
    publisher = var.self_hosted_image_publisher
    offer     = var.self_hosted_image_offer
    sku       = var.self_hosted_image_sku
  }
}

resource "time_rotating" "time-rotation" {
  rfc3339         = "2023-11-20T00:00:00Z"
  rotation_months = 1
}

resource "azurerm_resource_group" "automation_resource_group" {
  name     = "rg-${local.prefix}"
  location = var.location
}

resource "null_resource" "packer_runner" {
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset("${path.cwd}/runner-images-main/images/linux", "**") : filesha1("${path.cwd}/runner-images-main/images/linux/${f}")]))
    build_month = time_rotating.time-rotation.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = <<EOT
        packer build -var "client_id=${var.spn-client-id}" \
             -var "client_secret=${var.spn-client-secret}" \
             -var "location=${var.location}" \
             -var "subscription_id=${var.subscription-id}" \
             -var "temp_resource_group_name=temp-rg-${local.prefix}" \
             -var "tenant_id=${var.spn-tenant-id}" \
             -var "virtual_network_name=$null" \
             -var "virtual_network_resource_group_name=$null" \
             -var "virtual_network_subnet_name=$null" \
             -var "run_validation_diskspace=false" \
             -var "managed_image_name=${azurerm_shared_image.image.name}" \
             -var "managed_image_resource_group_name=${azurerm_resource_group.automation_resource_group.name}" \
             -color=false \
             "${local.imagePath}" 
    EOT

    environment = {
      POWERSHELL_TELEMETRY_OPTOUT = 1
    }
  }
}

data "azurerm_image" "image" {
  name                = azurerm_shared_image.image.name
  resource_group_name = azurerm_resource_group.automation_resource_group.name

  depends_on = [null_resource.packer_runner]
}

resource "azurerm_shared_image_version" "example" {
  name                = "0.0.2"
  gallery_name        = azurerm_shared_image.image.gallery_name
  image_name          = azurerm_shared_image.image.name
  resource_group_name = azurerm_shared_image.image.resource_group_name
  location            = azurerm_shared_image.image.location
  managed_image_id    = data.azurerm_image.image.id

  target_region {
    name                   = azurerm_shared_image.image.location
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }
}

module "scale_set"{
  source = "./virtual_machine_scale_set"

  resource_group_name = azurerm_resource_group.automation_resource_group.name
  location = azurerm_resource_group.automation_resource_group.location

  sku = "Standard_DS1_v2"
  gallery_image_id = azurerm_shared_image_version.example.id
}
