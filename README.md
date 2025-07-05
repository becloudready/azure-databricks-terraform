
# Azure Databricks DR/BCP Deployment

Goal of this repo is to develop Databricks DR automation based on best practice suggested by various DB articles.

![image](https://github.com/user-attachments/assets/048836f1-447e-42dc-b50c-90285859f2a9)


This Terraform configuration deploys:

- A Databricks workspace (Premium tier)
- A VNet with:
  - Public and private subnets
  - Subnet delegation for Databricks
  - NSG (Network Security Group) attachments
- VNet injection for secure Databricks deployment
- Support for Active/Passive DR setup across regions


## 🛠️ Requirements

- Terraform >= 1.3
- Azure CLI (`az login`)
- Sufficient Azure permissions to create resources

```
az account set --subscription "<your-subscription-name-or-id>"

```

## Create resource group

```
az group create \
  --name databricks-demo \
  --location eastus

```

```
az storage account create \
  --name bcrterraformstatefiles \
  --resource-group databricks-demo \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false


az storage account keys list \
  --account-name bcrterraformstatefiles \
  --resource-group databricks-demo \
  --query "[0].value" \
  -o tsv

az storage container create \
  --name tfstate \
  --account-name bcrterraformstatefiles \
  --account-key <YOUR_STORAGE_ACCOUNT_KEY>


```

---

## 🚀 How to Deploy the Infrastructure

```bash
# Step into the environment folder
cd infra/prod/eastus

# Initialize the Terraform project
terraform init

# Preview what will be created
terraform plan -var-file="terraform.tfvars"

# Apply the infrastructure
terraform apply -var-file="terraform.tfvars"
````
** Wait for 5 minutes before login to the workspace **

---

##  How to Deploy the Jobs/Code

```bash

export DATABRICKS_HOST="https://<Databricks-instance-id>.cloud.databricks.com"
export DATABRICKS_TOKEN="<YOUR-PAT>"

cd /apps/dev
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply --auto-approve -var-file="terraform.tfvars"

```


## 🧹 To Destroy

```bash
terraform destroy -var-file="terraform.tfvars"
```

---

## ✅ Outputs

After deployment, you'll get:

* `databricks_host` — URL to access your Databricks workspace

---

## 📝 Notes

* Adjust the `terraform.tfvars` to match region and resource group for each deployment.
* Use additional folders like `westus` for DR/secondary regions.

