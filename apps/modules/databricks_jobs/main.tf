

resource "databricks_notebook" "nightly_job_notebook" {
  path     = "/Shared/nightly_tasks"
  language = "PYTHON"
  content_base64 = base64encode(file(var.notebook_file_path))
}

resource "databricks_job" "nightly_serverless_job" {
  name = "Nightly SKU Alert Job - Serverless"

  task {
    task_key = "nightly-task"
    notebook_task {
      notebook_path = databricks_notebook.nightly_job_notebook.path
    }
  }

  schedule {
    quartz_cron_expression = "0 0 * * * ?"  # Every day at 00:00 UTC
    timezone_id            = "UTC"
    pause_status           = "UNPAUSED"
  }

  max_retries     = 1
  timeout_seconds = 3600

  tags = {
    team     = "platform"
    env      = "prod"
    schedule = "nightly"
  }
}
