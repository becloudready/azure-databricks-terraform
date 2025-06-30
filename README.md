
# Azure Databricks DR/BCP Deployment

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

---

## 🚀 How to Deploy

```bash
# Step into the environment folder
cd environments/prod/eastus

# Initialize the Terraform project
terraform init

# Preview what will be created
terraform plan -var-file="terraform.tfvars"

# Apply the infrastructure
terraform apply -var-file="terraform.tfvars"
````
** Wait for 5 minutes before login to the workspace **

---

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

