traffic_weights = [
  {
    revision_suffix = "r22",
    percentage      = 70
  },
  {
    revision_suffix = "r1",
    percentage      = 30
  }
]

image_repository = "mcr.microsoft.com"
image_name    = "azuredocs/aci-helloworld"
image_version = "latest"