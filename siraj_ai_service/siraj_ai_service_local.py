import os
import re
import tempfile
from datetime import datetime

from flask import Flask, request, jsonify
import requests
import whisper  # نموذج Whisper المحلي

# =========================
# إعدادات عامة
# =========================

# عنوان سيرفر مركز العمليات (الداشبورد)
# غيّره لو سيرفر العمليات في جهاز / بورت مختلف
OPS_DASHBOARD_URL = os.environ.get("SIRAJ_OPS_URL", "http://127.0.0.1:5000")

# تحميل نموذج Whisper المحلي مرة وحدة عند تشغيل السيرفر
# تقدر تغيّر "base" إلى: tiny / small / medium حسب قدرات الجهاز
WHISPER_MODEL_NAME = os.environ.get("SIRAJ_WHISPER_MODEL", "base")
print(f"[سِراج] جاري تحميل نموذج Whisper المحلي: {WHISPER_MODEL_NAME}...")
WHISPER_MODEL = whisper.load_model(WHISPER_MODEL_NAME)
print("[سِراج] تم تحميل نموذج Whisper بنجاح ✅")

app = Flask(__name__)


# =========================
# 1) تحويل الصوت إلى نص (Speech-to-Text) محلي
# =========================

def transcribe_audio_local(file_storage) -> str:
    """
    يستقبل ملف audio من Flask (FileStorage) ويحوّله لنص عربي باستخدام Whisper المحلي.
    لا يوجد أي اتصال خارجي هنا.
    """
    if file_storage is None:
        return ""

    # نحفظ الملف مؤقتًا
    with tempfile.NamedTemporaryFile(delete=False, suffix=".m4a") as tmp:
        file_storage.save(tmp.name)
        tmp_path = tmp.name

    try:
        # Whisper يستخدم ffmpeg داخليًا، فيكفي تمرير مسار الملف
        result = WHISPER_MODEL.transcribe(
            tmp_path,
            language="ar",   # نحاول نثبّت على العربية
            fp16=False       # لو ما عندك GPU أو ما تدعم fp16
        )
        text = (result.get("text") or "").strip()
    finally:
        try:
            os.remove(tmp_path)
        except OSError:
            pass

    return text


# =========================
# 2) تحليل النص وتحديد النوع والجهات (NLP بسيط محلي)
# =========================

def classify_report(text: str):
    """
    يأخذ نص البلاغ (بعد دمج الصوت + الكتابة)
    ويرجع:
      - category: fire / medical / traffic / other
      - agencies: list[str]
      - inferred_location: نص بسيط للموقع لو قدر نطلعه
    """
    # تبسيط الأحرف العربية
    t = (
        text.replace("أ", "ا")
            .replace("إ", "ا")
            .replace("آ", "ا")
            .replace("ى", "ي")
            .lower()
    )

    # قواعد بسيطة بالـ keywords - تقدر تطورها براحتك
    is_fire = any(k in t for k in ["حريق", "حري", "نار", "يحترق", "دخان", "تسرب غاز", "غاز", "لهب"])
    is_medical = any(
        k in t
        for k in [
            "اغماء",
            "فاقد الوعي",
            "لا يتنفس",
            "نزيف",
            "اسعاف",
            "حالته خطيره",
            "طبية",
            "مريض",
            "ازمة قلبية",
            "جلطه",
            "سكتة"
        ]
    )
    is_traffic = any(
        k in t
        for k in [
            "حادث",
            "تصادم",
            "اصطدام",
            "سيارات",
            "سيارة منقلبة",
            "دهس",
            "تفحيط",
            "طريق",
            "حادث مروري"
        ]
    )
    has_obstacle = any(
        k in t
        for k in [
            "زيت",
            "ماء في الشارع",
            "مويه في الشارع",
            "حفرة",
            "حفره",
            "تسريب",
            "مخلفات",
            "عوائق",
            "طين",
            "صبة مكسورة",
            "رصيف مكسور"
        ]
    )
    might_need_police = any(
        k in t
        for k in ["مشاجرة", "مشاجره", "اطلاق نار", "سلاح", "سرقة", "تهديد", "اطلاق", "جريمة", "اعتداء"]
    )

    # تحديد التصنيف الأساسي
    if is_fire:
        category = "fire"
    elif is_medical:
        category = "medical"
    elif is_traffic:
        category = "traffic"
    else:
        category = "other"

    # الجهات بناءً على القواعد
    agencies = set()

    # دفاع مدني
    if is_fire or "تسرب غاز" in t or "انهيار" in t:
        agencies.add("الدفاع المدني")

    # هلال أحمر + تجمع صحي
    if is_medical or "اصابه" in t or "جرح" in t or is_traffic:
        agencies.add("الهلال الأحمر")
        agencies.add("التجمع الصحي")

    # الدوريات الأمنية
    if is_traffic or might_need_police:
        agencies.add("الدوريات الأمنية")

    # الأمانة
    if has_obstacle or "زيت" in t or "حفره" in t or "حفرة" in t:
        agencies.add("الأمانة")

    # لو ما طلع شيء نهائيًا، نخلي أقل شيء هلال أحمر + دوريات
    if not agencies:
        agencies.update(["الهلال الأحمر", "الدوريات الأمنية"])

    inferred_location = extract_simple_location(text)

    return category, sorted(list(agencies)), inferred_location


def extract_simple_location(text: str) -> str:
    """
    محاولة بسيطة لاستخراج وصف مكان من النص، مثلاً:
    'في حي النرجس في الرياض' → 'حي النرجس، الرياض'
    كل هذا محلي بدون أي استدعاء لنموذج.
    """
    # محاولات بسيطة على "حي X"
    match = re.search(r"حي\s+([^\s،.]+)", text)
    hay = ""
    if match:
        # نأخذ "حي النرجس" وليس الكلمة فقط
        hay = "حي " + match.group(1)

    # أمثلة على مدن شائعة
    city_candidates = ["الرياض", "جدة", "مكة", "الدمام", "المدينة", "الخبر", "تبوك", "الطائف"]
    city_found = ""
    for c in city_candidates:
        if c in text:
            city_found = c
            break

    if hay and city_found:
        return f"{hay}، {city_found}"
    elif hay:
        return hay
    elif city_found:
        return city_found
    else:
        return "الموقع غير محدد نصيًا"


def build_title(text: str, category: str) -> str:
    """
    نبني عنوان مختصر للبلاغ بناءً على النص والتصنيف.
    كلّه محلي بدون LLM ولا API.
    """
    # نأخذ أول جملة لو شكلها مناسب
    sentence = re.split(r"[.!؟\n]", text.strip())
    first_sentence = sentence[0].strip() if sentence and sentence[0].strip() else ""

    if 8 < len(first_sentence) < 80:
        return first_sentence

    if category == "fire":
        return "بلاغ عن حريق"
    elif category == "medical":
        return "بلاغ عن حالة طبية"
    elif category == "traffic":
        return "بلاغ عن حادث مروري"
    else:
        return "بلاغ طارئ عبر سِراج"


# =========================
# 3) إرسال البلاغ إلى مركز العمليات (Flask dashboard)
# =========================

def send_report_to_ops_dashboard(report_payload: dict):
    """
    يرسل JSON إلى /api/reports في سيرفر مركز العمليات.
    هذا هو الربط بين "ذكاء سِراج" وواجهة الجهات.
    """
    url = f"{OPS_DASHBOARD_URL}/api/reports"
    try:
        resp = requests.post(url, json=report_payload, timeout=5)
        resp.raise_for_status()
        data = resp.json()
        return data
    except Exception as e:
        print("خطأ أثناء إرسال البلاغ إلى مركز العمليات:", e)
        return {"ok": False, "error": str(e)}


# =========================
# 4) API رئيسية لسِراج AI (محلي بالكامل)
# =========================

@app.route("/analyze", methods=["POST"])
def analyze_report():
    """
    يستقبل:
      - text: نص البلاغ (اختياري)
      - audio: ملف صوتي (اختياري)
      - source: مصدر البلاغ (توكلنا / غيره) - اختياري

    يقوم بـ:
      1) تحويل الصوت لنص محليًا (Whisper المحلي).
      2) دمج النص المكتوب + الصوتي.
      3) تحليل النص بقواعد بسيطة لاختيار الجهات والتصنيف.
      4) بناء Payload وإرساله إلى /api/reports في مركز العمليات.
    """

    # 1) النص المكتوب - لو فيه
    raw_text = (request.form.get("text") or "").strip()
    source = (request.form.get("source") or "توكلنا").strip()

    # 2) الملف الصوتي - لو فيه
    audio_file = request.files.get("audio")
    audio_text = ""

    if audio_file:
        audio_text = transcribe_audio_local(audio_file)
        print("[سِراج] نص مستخرج من الصوت:", audio_text)

    # 3) دمج النصوص
    combined_text_parts = []
    if raw_text:
        combined_text_parts.append(raw_text)
    if audio_text:
        combined_text_parts.append(audio_text)

    if not combined_text_parts:
        return jsonify({"error": "لا يوجد نص أو ملف صوتي في الطلب."}), 400

    final_text = "\n".join(combined_text_parts).strip()

    # 4) تحليل النص وتحديد النوع والجهات
    category, agencies, inferred_location = classify_report(final_text)

    # 5) بناء بيانات البلاغ
    title = build_title(final_text, category)
    now = datetime.now()
    created_at_str = "الآن"
    received_at_str = now.strftime("%Y-%m-%d %H:%M")

    payload = {
        "title": title,
        "category": category,
        "status": "جاري المعالجة",
        "location": inferred_location,
        "area": inferred_location,
        "created_at": created_at_str,
        "received_at": received_at_str,
        "short_description": final_text[:280],  # نلخص بس أول 280 حرف
        "agencies": agencies,
        "map_top": "50%",   # تقدر تربطه لاحقًا بـ GIS
        "map_left": "50%",
    }

    # 6) إرسال البلاغ لمركز العمليات
    result = send_report_to_ops_dashboard(payload)

    return jsonify(
        {
            "ok": True,
            "classification": {
                "category": category,
                "agencies": agencies,
                "inferred_location": inferred_location,
            },
            "final_text": final_text,
            "ops_dashboard_result": result,
        }
    ), 201


if __name__ == "__main__":
    # مثال تشغيل: python siraj_ai_service_local.py
    # يشغّل سيرفر ذكاء سِراج على بورت 8000
    app.run(host="0.0.0.0", port=8000, debug=True)
