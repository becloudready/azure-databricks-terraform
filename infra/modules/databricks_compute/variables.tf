variable "cluster_name" {
  description = "Databricks cluster name"
  type        = string
  default     = "example-cluster"
}

variable "num_workers" {
  description = "Number of workers"
  type        = number
  default     = 2
}
