import ollama
from schema_loader import load_schema, filtrele_tablo, llm_formatla

def esleştirme_promptu_olustur(hedef_satirlar: list, kaynak_satirlar: list) -> str:
    hedef_metin = llm_formatla(hedef_satirlar)
    kaynak_metin = llm_formatla(kaynak_satirlar)
    
    return f"""Sen bir BigQuery SQL uzmanısın. Görevin iki tablo arasında sütun eşleştirmesi yapıp SELECT SQL yazmak.

## KURALLAR
1. HEDEF TABLO sütun sırasını koru
2. Kaynak tabloda eşleşen sütunu bul, AS ile yaz
3. Bulamazsan: NULL AS missing_[hedef_sütun_adı]
4. Tip farkı varsa CAST kullan
5. Sadece SQL yaz, açıklama yapma

## HEDEF TABLO (bu sütun sırasını üret)
{hedef_metin}

## KAYNAK TABLO (buradan SELECT yap)
{kaynak_metin}

## ÇIKTI
SELECT
  ...
FROM `hb-analysis-prod.delivery.delivery_dm_initial_order_sku_daily`
"""

def llm_calistir(prompt: str, model: str = "qwen2.5-coder:latest") -> str:
    response = ollama.chat(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        options={"num_ctx": 16384}  
    )
    return response["message"]["content"]

if __name__ == "__main__":
    # Tabloları yükle
    kpi_schema = load_schema("kpi_schema.json")
    delivery_schema = load_schema("delivery_schema.json")
    
    hedef = filtrele_tablo(kpi_schema, "time_differences_all_delta")
    kaynak = filtrele_tablo(delivery_schema, "delivery_dm_initial_order_sku_daily")
    
    prompt = esleştirme_promptu_olustur(hedef, kaynak)
    
    print("LLM çalışıyor, bekle...\n")
    sonuc = llm_calistir(prompt)
    
    print(sonuc)
    
    # Çıktıyı kaydet
    with open("outputs/mapping_output.sql", "w", encoding="utf-8") as f:
        f.write(sonuc)
    
    print("\n✅ outputs/mapping_output.sql dosyasına kaydedildi")