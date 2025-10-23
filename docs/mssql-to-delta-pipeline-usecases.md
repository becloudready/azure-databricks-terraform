# Databricks Pipelines for MSSQL ➜ Delta Lake

This repository provisions the core building blocks (Databricks workspace, networking, and scheduled jobs) that you can extend into full ingestion pipelines. For example, the Terraform module in `apps/modules/databricks_jobs/main.tf` already deploys a nightly job that runs the `nightly_sku_alert_job.py` notebook, which writes alerts to Delta tables on a schedule. Building on top of these components makes it straightforward to orchestrate reliable pipelines that land data from Microsoft SQL Server into Delta Lake.

## Reference Ingestion Pattern

1. **Source extraction** – Use Databricks' JDBC connector or Databricks SQL warehouse to pull data from on-premises or Azure SQL-managed MSSQL instances. Parameterize connection secrets through Databricks secret scopes and run extraction as part of a scheduled job (e.g., extending the job defined in `apps/dev/main.tf`).
2. **Landing/Bronze layer** – Persist raw extracts into Delta tables in a bronze schema, keeping a full-fidelity copy for audit and replay.
3. **Incremental processing** – Apply change data capture (CDC) logic (e.g., SQL Server temporal tables or Debezium feeds) to upsert into silver tables, leveraging Delta Lake MERGE operations for deduplication and slowly changing dimensions.
4. **Serving/Gold layer** – Curate aggregates or feature tables that feed downstream notebooks such as `notebooks/nightly_sku_alert_job.py` for operational alerting or ML workloads.

## Use Cases

### 1. Daily Sales Snapshot and Forecast Alignment
- **Business Goal:** Keep sales order data from MSSQL synchronized with planning models that power the nightly SKU alert notebook.
- **Pipeline Flow:** A nightly Databricks job (defined with `databricks_job` in the Terraform module) pulls incremental sales orders via JDBC, appends them to a bronze Delta table, and refreshes silver/gold tables that the `nightly_sku_alert_job.py` notebook queries before writing alerts to Delta.
- **Key Considerations:** Schedule alignment with ERP cutoffs, parameterized notebook widgets for date filters, and alerting on row count anomalies using notebook exit status.

### 2. Inventory and Supply Chain Visibility (Multi-Region DR)
- **Business Goal:** Synchronize master inventory data from regional MSSQL sources into Delta so that the active and passive Databricks workspaces deployed by this repo have consistent views during a disaster recovery (DR) event.
- **Pipeline Flow:** Use Azure Data Factory or Databricks Autoloader to land staged parquet/CSV exports from MSSQL into blob storage, then trigger a Databricks pipeline to MERGE data into bronze/silver Delta tables replicated across regions. Terraform's multi-region VNet and workspace pattern ensures the same pipeline definition can be promoted to DR regions.
- **Key Considerations:** Geo-redundant storage accounts for landing zones, workspace parameterization through `terraform.tfvars`, and idempotent MERGE logic to support replay during failover testing.

### 3. Change Data Capture for Customer 360
- **Business Goal:** Maintain a continuously updated customer profile store by applying MSSQL CDC feeds to Delta Lake.
- **Pipeline Flow:** Stream CDC events (via Azure Event Hubs or Kafka) into Databricks using structured streaming. A Delta Live Tables (DLT) pipeline—or a streaming notebook scheduled like the existing job—hydrates bronze change tables and applies `MERGE` into silver/gold customer tables that analytics teams query.
- **Key Considerations:** Configure Auto Loader with `cloudFiles` for schema drift, enforce expectations in DLT for data quality, and persist checkpoints in the workspace's default storage configured by the Terraform deployment.

### 4. Financial Close and Compliance Reporting
- **Business Goal:** Automate end-of-month extracts from MSSQL-based finance systems into auditable Delta tables used for compliance reporting.
- **Pipeline Flow:** On-demand or scheduled jobs run parameterized notebooks that snapshot MSSQL ledger tables, write immutable Delta versions tagged with reporting period metadata, and archive copies to long-term storage.
- **Key Considerations:** Use job-level parameters (set in Terraform) to drive reporting periods, implement Delta time travel for audit reviews, and integrate with access controls provisioned in Databricks for finance teams.

## Next Steps

- Parameterize the existing Terraform module to accept connection secrets and notebook paths dedicated to MSSQL ingestion workloads.
- Extend `nightly_sku_alert_job.py` (or create new notebooks) to include extraction and Delta MERGE logic alongside the alerting steps.
- Leverage the DR-friendly infrastructure provided in `infra/` to deploy identical pipelines across primary and secondary regions.
