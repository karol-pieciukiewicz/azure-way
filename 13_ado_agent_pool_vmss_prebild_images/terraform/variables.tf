variable "app_name" {
  default = "agentpool"
}

variable "location" {
  default = "westeurope"
}

variable "sku" {
  default = "Standard_DS1_v2"
}

variable "community_image" {
  description = "Community image type: possible values: ubuntu-2004, ubuntu-2204, ubuntu-2404, windows-2019, windows-2022"
}

variable "community_image_version" {
  description = "Community image version"
  default = "latest"
}

variable "shared_images" {
  type = map(string)
  default = {
    "ubuntu-2004" = "/sharedGalleries/azureway_community_gallery/images/azureway-u-20.04/versions/"
    "ubuntu-2204" = "/sharedGalleries/azureway_community_gallery/images/azureway-u-22.04/versions/"
    "ubuntu-2404" = "/sharedGalleries/azureway_community_gallery/images/azureway-u-24.04/versions/"
    "windows-2019" = "/sharedGalleries/azureway_community_gallery/images/azureway-w-2019/versions/"
    "windows-2022" = "/sharedGalleries/azureway_community_gallery/images/azureway-w-2022/versions/"
  }
}

