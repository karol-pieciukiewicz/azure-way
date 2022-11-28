Detailed description you can find in [AzureWay blog](https://azureway.cloud/self-hosted-agent-on-linux-with-azure-container-instances/)

## Login to Azure CLI and subscription set
```
az login
az account list
az account set --subscription ##SUBSCRIPTION##
```

## Azure DevOps agnet image build and pushing to ACR
```
az acr build --registry ##REGISTRY_NAME## --image adobuildagent:v1 .
```

## Creation of Azure Container Instances in selected VNET
```
az container create -g ##RESROUCE_GROUP##--registry-login-server ##ACR_URL## --registry-username ##ACR_USER## --registry-password ##ACR_USER_PASS## --name ##ACI_CONTAINER_NAME## --image ##IMAGE_ADDRESS## --vnet ##VNET_NAME## --subnet ##SUBNET_NAME## --environment-variables AZP_TOKEN=##DEVOPS_PERSONAL_TOKEN## AZP_URL=##DEVOPS_ORGANIZATION_URL##
```