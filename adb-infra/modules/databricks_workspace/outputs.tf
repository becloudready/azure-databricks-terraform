output "workspace_url" {
  description = "URL of the deployed Databricks workspace"
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "workspace_id" {
  description = "ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.id
}
