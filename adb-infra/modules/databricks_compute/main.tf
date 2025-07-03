

# Fetch the smallest node type and latest runtime version
data "databricks_node_type" "smallest" {
    local_disk = true
}

data "databricks_spark_version" "latest_lts" {
    long_term_support = true
}

# Create the Databricks cluster
resource "databricks_cluster" "example_cluster" {
    cluster_name = var.cluster_name
    spark_version = data.databricks_spark_version.latest_lts.id
    node_type_id = data.databricks_node_type.smallest.id
    autotermination_minutes = 10
    num_workers = var.num_workers
}

resource "databricks_notebook" "example" {
    path            = "/Shared/example_notebook"
    language        = "PYTHON"
    format          = "SOURCE"
    content_base64  = base64encode(file("${path.module}/example_notebook.py"))
}

# Output the cluster URL
output "cluster_url" {
    value = databricks_cluster.example_cluster.url
}