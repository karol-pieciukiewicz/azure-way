az account list
az account set --subscription ##SUBSCRIPTION##

# naviage to directory with dockerfile
# build and push image to ACR
az acr build --registry ##REGISTRY_NAME## --image adobuildagent:v1 .

# create ACI with agent image
az container create -g ##RESROUCE_GROUP##--registry-login-server ##ACR_URL## --registry-username ##ACR_USER## --registry-password ##ACR_USER_PASS## --name ##ACI_CONTAINER_NAME## --image ##IMAGE_ADDRESS## --vnet ##VNET_NAME## --subnet ##SUBNET_NAME## --environment-variables AZP_TOKEN=##DEVOPS_PERSONAL_TOKEN## AZP_URL=##DEVOPS_ORGANIZATION_URL##