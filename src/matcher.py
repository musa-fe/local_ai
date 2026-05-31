import ollama
import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from schema_loader import load_schema, filtrele_tablo, llm_formatla
from config import *

def prompt_olustur(scheduled_query, kaynak_satirlar, hedef_satirlar):
    with open("prompts/migration_prompt.txt", "r", encoding="utf-8") as f:
        sablon = f.read()
    return sablon.format(
        scheduled_query=scheduled_query,
        kaynak_schema=llm_formatla(kaynak_satirlar),
        hedef_schema=llm_formatla(hedef_satirlar)
    )

def llm_calistir(prompt):
    response = ollama.chat(
        model=MODEL,
        messages=[{"role": "user", "content": prompt}],
        options={"num_ctx": 16384}
    )
    return response["message"]["content"]

if __name__ == "__main__":
    with open(SCHEDULED_QUERY_DOSYASI, "r", encoding="utf-8") as f:
        scheduled_query = f.read()

    kaynak_schema = load_schema(KAYNAK_DATASET_DOSYASI)
    hedef_schema = load_schema(HEDEF_DATASET_DOSYASI)

    kaynak = filtrele_tablo(kaynak_schema, KAYNAK_TABLO)
    hedef = filtrele_tablo(hedef_schema, HEDEF_TABLO)

    prompt = prompt_olustur(scheduled_query, kaynak, hedef)

    print("LLM çalışıyor, bekle...\n")
    sonuc = llm_calistir(prompt)

    print(sonuc)

    with open(OUTPUT_DOSYASI, "w", encoding="utf-8") as f:
        f.write(sonuc)

    print(f"\n✅ {OUTPUT_DOSYASI} dosyasına kaydedildi")