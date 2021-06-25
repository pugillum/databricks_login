# databricks_login

This shows how to login and use databricks CLI from a Github Actions pipeline
and request a token for a service principal (rather than using a PAT)

## Requirements
- a Databricks workspace
- a Service Principal that can access the Databricks workspace

## Secret

You will need to add a secret called SP_CREDENTIALS

The secret should look like this:
```
{
  "clientId": "CLIENT ID OF YOUR SERVICE PRINCIPAL",
  "clientSecret": "SECRET OF YOUR SERVICE PRINCIPAL",
  "subscriptionId": "YOUR SUBSCRIPTION ID",
  "tenantId": "YOUR TENANT ID",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```
