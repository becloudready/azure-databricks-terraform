from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when
from pyspark.sql.functions import abs
from pyspark.sql.functions import current_date

# Initialize Spark session (you can skip this on Databricks notebooks)
spark = SparkSession.builder.appName("ForecastDelta").getOrCreate()

# Load tables from Databricks catalog
sales_df = spark.table("workspace.share_point.sales_team_forecast")
consensus_df = spark.table("workspace.share_point.supply_chain_consensus")

# Join on SKU and select required columns
joined_df = sales_df.join(consensus_df, on="sku") \
    .select(
        sales_df.brand,
        sales_df.sku,
        sales_df.sales_forecast,
        consensus_df.consensus_call,
        (sales_df.sales_forecast - consensus_df.consensus_call).alias("delta")
    ) \
    .limit(1000)

# Add optional alert message column (if needed)
joined_with_alerts = joined_df.withColumn(
    "alert_msg",
    when(col("delta") > 0, "Cut Production")
    .when(col("delta") < 0, "Add Production")
    .otherwise("No Action")
)

# Show results (or write to file/table)
joined_with_alerts.show(truncate=False)


# Filter SKUs with absolute delta > 500
critical_skus_df = joined_with_alerts.filter(abs(col("delta")) > 500)

# Show the list (or export it)
critical_skus_df.select("sku", "brand", "sales_forecast", "consensus_call", "delta", "alert_msg").show(truncate=False)


# Add a date column to track when the alert was generated
alerts_with_date = critical_skus_df.withColumn("alert_date", current_date())

# Save to a Delta table (or overwrite/create if first time)
alerts_with_date.write.mode("append").format("delta").saveAsTable("alerts_log")

print("Alerts written to table: alerts_log")

