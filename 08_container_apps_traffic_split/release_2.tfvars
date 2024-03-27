traffic_weights = [
  {
    latest_revision = false,
    revision_suffix = "r22",
    percentage      = 70
  },
  {
    latest_revision = false,
    revision_suffix = "r1",
    percentage      = 30
  }
]

image_repository = "mcr.microsoft.com"
image_name    = "azuredocs/aci-helloworld"
image_version = "latest"
revision_suffix = "r22"