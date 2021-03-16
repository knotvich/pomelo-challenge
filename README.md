# pomelo-challenge

# Terraform 

This repository use GitHub Action and Terraform Cloud to Deploy Azure resource including resource group, virtual network, nat gateway, routing table, postgresql database and virtual runing golang web application which query data from[https://newsapi.org/v2/everything](https://newsapi.org/docs/endpoints/everything). The go codes derived from https://github.com/Freshman-tech/news-demo.

The workflow will:

1. The workflow will connect to Terraform Cloud to plan and apply your configuration
2. Use 'terraform fmt --check' commad to check whether the configuration is formatted properly to demonstrate how you can enforce best practices
3. Generate a plan for every pull requests
4. Apply the configuration when you update the master branch


## Preparation

GitHub account
Terraform Cloud account
Azure Service principle

### Set up Terraform Cloud

Create a workspace, add your Azure service credentials to your Terraform Cloud workspace, and generate a user API token.

1. Select organization and click at '+ New workspace' at corner right and select "API-driven workflow". Name your workspace 'pomelo-devops-challenge' and click "Create workspace".

2. [Creating Azure Service Principle](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform) and add values to Environment variables for 'pomelo-devops-challenge' workspace.

ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID

3. Go to User Settings and click on[Create an API Tokens](https://app.terraform.io/app/settings/tokens) and generate an API token named 'github-actions'. Save it as you will have to add it to GitHub secret later

### Set up a GitHub repository

Fork this reposiory into your own GitHub account

1. Go to 'Setting' --> 'Secret' and create a new secret named 'TF_API_TOKEN' using Terraform Cloud API Tokens you created earlier

2. Sellect the "Actions" tab and enable this pre-configured workflow by clicking "I understand my workflows, go ahead and enable them."

3. Clone forked repository to local machine


### Set up a web application environment variables

Specify environment variables in web/.env files as it will be use to run web application

'PORT' - Web listening port 
'NEWS_API_KEY' - API KEY to query [News API](https://newsapi.org/)by sign up and receive free API Key [here](https://newsapi.org/register)

### Set up Terraform variables

Specify terraform variables in variable.tf

'prefix' -  Prefix that will be used in naming of the azure resource
'virtual_network_address_space' -  address space, for example "10.0.0.0/16"
'virtual_network_default_subnet' - default subnet, for example
'ssh_public_key_file_path' -  path of the ssh public key that will be used to ssh into virtual machine
'ssh_private_key_file_path' - path of the ssh private key that will be used to ssh into virtual machine
'postgresql_server_name' - postgresql server hostname 
'postgresql_db_username' - administrator username of postgresql server
'postgresql_db_password' - administrator password of postgresql server


## Usage

Initialize terrraform to download plugin that allows Terraform to interact with Azure resource manager

```bash
terraform init
```

Show infrastructure changes that will be updated by the current configuration
```bash
terraform plan
```

Create or update infrastructure
```bash
terraform apply
```



