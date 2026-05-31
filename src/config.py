# Sadece burayı değiştirirsin
KAYNAK_DATASET_DOSYASI = "delivery_schema.json"
KAYNAK_TABLO = "delivery_dm_initial_order_sku_daily"

HEDEF_DATASET_DOSYASI = "kpi_schema.json"
HEDEF_TABLO = "time_differences_all_delta"

SCHEDULED_QUERY_DOSYASI = "prompts/scheduled_query.sql"
OUTPUT_DOSYASI = "outputs/migration_output.sql"

MODEL = "qwen2.5-coder:latest"