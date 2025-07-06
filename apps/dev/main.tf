terraform {
  required_version = ">= 1.4.0"
}

module "nightly_serverless_job" {
  source = "../modules/databricks_jobs"
  notebook_file_path = "${path.module}/../../notebooks/nightly_sku_alert_job.py"
}

output "debug_notebook_path" {
  value = var.notebook_file_path
}
