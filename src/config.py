# Tablo bilgileri
KAYNAK_TABLO_FULL = "hb-analysis-prod.delivery.delivery_dm_initial_order_sku_daily"
KAYNAK_DATASET_DOSYASI = "delivery_schema.json"
KAYNAK_TABLO = "delivery_dm_initial_order_sku_daily"

HEDEF_DATASET_DOSYASI = "kpi_schema.json"
HEDEF_TABLO = "time_differences_all_delta"

SCHEDULED_QUERY_DOSYASI = "prompts/scheduled_query.sql"
OUTPUT_DOSYASI = "outputs/migration_output.sql"

# Test edilecek modeller
MODELLER = [
    "qwen2.5-coder:latest",
    "deepseek-coder-v2",
    "qwen2.5-coder:14b",
    "yi-coder",
]
TEKRAR_SAYISI = 2  # 3 yerine 2, zaman kazanalım,

# Tek model çalıştırma için (matcher.py kullanır)
MODEL = "qwen2.5-coder:latest"