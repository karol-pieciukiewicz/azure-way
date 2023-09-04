locals {
#   fd_profile_name         = "${var.fd_name}FrontDoor"
#   fd_endpoint_name        = "afd-${lower(random_id.fd_endpoint_name.hex)}"
#   fd_origin_group_name    = "${var.fd_name}OriginGroup"
#   fd_origin_name          = "${var.fd_name}BlobContainerOrigin"
#   fd_route_name           = "${var.fd_name}Route"
#   fd_origin_path          = "/${var.storage_account_blob_container_name}" // The path to the blob container.
#   fd_custom_domain_name   = "${var.fd_name}CustomDomain"
}

resource "random_pet" "rg" {}

resource "azurerm_resource_group" "my_resource_group" {
  name     = "${var.resource_group_name}-${random_pet.rg.id}"
  location = var.location
}

resource "random_id" "fd_endpoint_name" {
  byte_length = 4
}

resource "azurerm_cdn_frontdoor_profile" "my_front_door" {
  name                = "${var.fd_name}FrontDoor"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  sku_name            = var.fd_sku_name
}

resource "azurerm_cdn_frontdoor_endpoint" "my_endpoint" {
  name                     = "afd-${lower(random_id.fd_endpoint_name.hex)}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
}

resource "azurerm_cdn_frontdoor_origin_group" "my_origin_group" {
  name                     = "${var.fd_name}OriginGroup"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  session_affinity_enabled = true

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "my_blob_container_origin" {
  name                          = "${var.fd_name}BlobContainerOrigin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id

  enabled                        = true
  host_name                      = azurerm_storage_account.my_storage_account.primary_blob_host
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_storage_account.my_storage_account.primary_blob_host
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true

  private_link {
    private_link_target_id = azurerm_storage_account.my_storage_account.id
    target_type            = "blob"
    request_message        = "Request access for Azure Front Door Private Link origin"
    location               = var.fd_private_link_location
  }
}

resource "azurerm_cdn_frontdoor_route" "my_route" {
  name                          = "${var.fd_name}Route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.my_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.my_blob_container_origin.id]

  supported_protocols       = ["Http", "Https"]
  patterns_to_match         = ["/*"]
  forwarding_protocol       = "HttpsOnly"
  link_to_default_domain    = true
  https_redirect_enabled    = true
  cdn_frontdoor_origin_path = "/${var.storage_account_blob_container_name}" 

  cache {
    query_string_caching_behavior = "UseQueryString"
  }

  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.my_custom_domain.id
  ]
}

resource "azurerm_cdn_frontdoor_custom_domain" "my_custom_domain" {
  name                     = "${var.fd_name}CustomDomain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  host_name                = var.custom_domain_name

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_firewall_policy" "my_waf_policy" {
  name                = "${var.fd_name}WAFPolicy"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  sku_name            = var.fd_sku_name
  enabled             = true
  mode                = var.waf_mode

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "my_security_policy" {
  name                     = "${var.fd_name}SecurityPolicy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.my_waf_policy.id

      association {
        patterns_to_match = ["/*"]

        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.my_custom_domain.id
        }
      }
    }
  }
}