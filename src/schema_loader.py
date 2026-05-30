import json
import os

SCHEMAS_DIR = "schemas/"

def load_schema(dosya_adi: str) -> list:
    """JSON schema dosyasını okur"""
    yol = os.path.join(SCHEMAS_DIR, dosya_adi)
    with open(yol, "r", encoding="utf-8") as f:
        return json.load(f)

def filtrele_tablo(schema: list, tablo_adi: str) -> list:
    """Belirli bir tablonun sütunlarını filtreler"""
    return [
        satir for satir in schema 
        if satir.get("table_name") == tablo_adi
    ]

def llm_formatla(satirlar: list) -> str:
    """LLM'e gönderilecek temiz metin formatı üretir"""
    if not satirlar:
        return "Tablo bulunamadı."
    
    tablo_adi = satirlar[0]["table_name"]
    tablo_tipi = satirlar[0]["table_type"]
    
    sonuc = f"Tablo: {tablo_adi} ({tablo_tipi})\n"
    sonuc += "Sütunlar:\n"
    
    for s in satirlar:
        desc = s.get("description") or ""
        desc_yazi = f" — {desc}" if desc else ""
        sonuc += f"  {s['ordinal_position']} | {s['column_name']} | {s['data_type']}{desc_yazi}\n"
    
    return sonuc

if __name__ == "__main__":
    # Test
    schema = load_schema("kpi_schema.json")
    satirlar = filtrele_tablo(schema, "time_differences_all_delta")
    print(llm_formatla(satirlar))