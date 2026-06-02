import ollama
import os
import sys
import json
import time
import re
from datetime import datetime

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from schema_loader import load_schema, filtrele_tablo, llm_formatla
from config import *


def prompt_olustur(scheduled_query: str, kaynak_satirlar: list, hedef_satirlar: list) -> str:
    with open("prompts/migration_prompt.txt", "r", encoding="utf-8") as f:
        sablon = f.read()
    return sablon.format(
        scheduled_query=scheduled_query,
        kaynak_schema=llm_formatla(kaynak_satirlar),
        hedef_schema=llm_formatla(hedef_satirlar),
        kaynak_tablo_full=KAYNAK_TABLO_FULL
    )


def llm_calistir(prompt: str, model: str) -> tuple:
    baslangic = time.time()
    try:
        response = ollama.chat(
            model=model,
            messages=[{"role": "user", "content": prompt}],
            options={"num_ctx": 16384, "temperature": 0}
        )
        sure = time.time() - baslangic
        return response["message"]["content"], sure
    except Exception as e:
        sure = time.time() - baslangic
        return f"HATA: {str(e)}", sure


def sql_cikar(metin: str) -> str:
    kod_blok = re.search(r"```sql\n(.*?)```", metin, re.DOTALL)
    if kod_blok:
        return kod_blok.group(1).strip()
    return metin.strip()


def skorla(uretilen_sql: str, hedef_satirlar: list, kaynak_satirlar: list, referans_sql: str) -> dict:
    sql = sql_cikar(uretilen_sql).lower()
    ref = referans_sql.lower()
    hedef_sutunlar = [s["column_name"].lower() for s in hedef_satirlar]

    skor = {}
    puan = 0

    # 1. Tek tablodan mı çekiyor (30 puan) — en kritik
    eski_tablolar = [
        "delivery_flat.delivery",
        "oms_flat.orderline",
        "oms_flat.order_initialorderline",
        "merchant_flat.merchant_taglist"
    ]
    kalan_join = sum(1 for t in eski_tablolar if t in sql)
    skor["eski_join_sayisi"] = kalan_join
    skor["tek_tablo"] = "✅" if kalan_join == 0 else f"❌ {kalan_join} eski tablo kaldı"
    if kalan_join == 0:
        puan += 30

    # 2. Hedef sütun kapsama (30 puan)
    bulunan = sum(1 for s in hedef_sutunlar if s in sql)
    kapsama = round(bulunan / len(hedef_sutunlar) * 100, 1)
    skor["sutun_kapsama"] = f"{bulunan}/{len(hedef_sutunlar)} (%{kapsama})"
    puan += round(kapsama * 0.30, 1)

    # 3. CASE/COALESCE mantığı (15 puan)
    case_ref = ref.count("case when")
    case_uretilen = sql.count("case when")
    coalesce_var = "coalesce" in sql
    skor["case_sayisi"] = f"ref:{case_ref} → üretilen:{case_uretilen}"
    if case_uretilen >= case_ref * 0.7:
        puan += 10
        skor["case_korunmus"] = "✅"
    else:
        skor["case_korunmus"] = f"❌ yeterince korunmadı"
    if coalesce_var:
        puan += 5
        skor["coalesce_korunmus"] = "✅"
    else:
        skor["coalesce_korunmus"] = "❌"

    # 4. WHERE filtreleri (15 puan)
    where_kontroller = [
        "merchant_to_customer",
        "hepsiburada",
        "standard",
        "interval -30 day",
        "interval -1 day"
    ]
    where_bulunan = sum(1 for w in where_kontroller if w in sql)
    skor["where_kapsama"] = f"{where_bulunan}/{len(where_kontroller)}"
    puan += round(where_bulunan / len(where_kontroller) * 15, 1)

    # 5. city_normalize (10 puan)
    if "city_normalize" in sql:
        puan += 10
        skor["city_normalize"] = "✅"
    else:
        skor["city_normalize"] = "❌"

    skor["toplam_puan"] = round(puan, 1)
    return skor


def benchmark_calistir():
    print("=" * 60)
    print("BigQuery Migration SQL Benchmark")
    print(f"Tarih: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print("=" * 60)

    # Dosyaları yükle
    with open(SCHEDULED_QUERY_DOSYASI, "r", encoding="utf-8") as f:
        scheduled_query = f.read()

    with open("prompts/reference_output.sql", "r", encoding="utf-8") as f:
        referans_sql = f.read()

    kaynak_schema = load_schema(KAYNAK_DATASET_DOSYASI)
    hedef_schema = load_schema(HEDEF_DATASET_DOSYASI)

    kaynak = filtrele_tablo(kaynak_schema, KAYNAK_TABLO)
    hedef = filtrele_tablo(hedef_schema, HEDEF_TABLO)

    prompt = prompt_olustur(scheduled_query, kaynak, hedef)

    sonuclar = {}

    for model in MODELLER:
        print(f"\n🤖 Model: {model}")
        print("-" * 40)

        model_sonuclari = []

        for i in range(TEKRAR_SAYISI):
            print(f"  Çalıştırma {i+1}/{TEKRAR_SAYISI}...", end=" ", flush=True)

            cikti, sure = llm_calistir(prompt, model)

            if cikti.startswith("HATA"):
                print(f"❌ {cikti}")
                model_sonuclari.append({
                    "cikti": cikti,
                    "sure": sure,
                    "skor": {"toplam_puan": 0}
                })
                continue

            skor = skorla(cikti, hedef, kaynak, referans_sql)
            print(f"✅ {sure:.1f}s | Puan: {skor['toplam_puan']}/100")

            # SQL çıktısını kaydet
            model_safe = model.replace('/', '_').replace(':', '_')
            dosya_adi = f"outputs/{model_safe}_run{i+1}.sql"
            with open(dosya_adi, "w", encoding="utf-8") as f:
                f.write(sql_cikar(cikti))

            model_sonuclari.append({
                "cikti": sql_cikar(cikti),
                "sure": round(sure, 1),
                "skor": skor
            })

        puanlar = [s["skor"]["toplam_puan"] for s in model_sonuclari]
        sureler = [s["sure"] for s in model_sonuclari]
        ort_puan = round(sum(puanlar) / len(puanlar), 1)
        ort_sure = round(sum(sureler) / len(sureler), 1)

        sonuclar[model] = {
            "ortalama_puan": ort_puan,
            "ortalama_sure": ort_sure,
            "detay": model_sonuclari
        }

        print(f"  → Ortalama Puan: {ort_puan}/100 | Ortalama Süre: {ort_sure}s")

        # Ara sonucu kaydet (crash olursa veri kaybolmasın)
        with open("benchmark/sonuclar.json", "w", encoding="utf-8") as f:
            json.dump(sonuclar, f, ensure_ascii=False, indent=2)

    # Özet tablo
    print("\n" + "=" * 60)
    print("SONUÇ TABLOSU")
    print("=" * 60)
    print(f"{'Model':<45} {'Puan':>8} {'Süre':>8}")
    print("-" * 60)

    sirali = sorted(sonuclar.items(), key=lambda x: x[1]["ortalama_puan"], reverse=True)
    for model, veri in sirali:
        print(f"{model:<45} {veri['ortalama_puan']:>7}/100 {veri['ortalama_sure']:>6}s")

    print("=" * 60)
    print(f"\n✅ Detaylı sonuçlar: benchmark/sonuclar.json")
    print(f"✅ SQL çıktıları: outputs/ klasöründe")


if __name__ == "__main__":
    benchmark_calistir()
