resource "databricks_notebook" "nightly_job_notebook" {
  path     = "/Shared/nightly_task"
  language = "PYTHON"
  content_base64 = base64encode(file("${path.module}/../../notebooks/nightly_forecast_job.py"))
}

resource "databricks_job" "nightly_serverless_job" {
  name = "Nightly Python Job - Serverless"

  notebook_task {
    notebook_path = databricks_notebook.nightly_job_notebook.path
  }

  schedule {
    quartz_cron_expression = "0 0 * * * ?"  # Every day at 00:00 UTC
    timezone_id            = "UTC"
    pause_status           = "UNPAUSED"
  }

  new_cluster {
    serverless = true                     # ✅ This enables serverless compute
    autotermination_minutes = 15
  }

  max_retries     = 1
  timeout_seconds = 3600

  tags = {
    "team"        = "platform"
    "env"         = "prod"
    "schedule"    = "nightly"
  }
}
