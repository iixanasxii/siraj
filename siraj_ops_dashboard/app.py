from flask import Flask, render_template, request, jsonify
from datetime import datetime

app = Flask(__name__)

# بيانات بلاغات وهمية كأنها جاية من الـ AI / تطبيق توكلنا
REPORTS = [
    {
        "id": "SRJ-1024",
        "title": "حريق في مبنى سكني",
        "category": "fire",  # fire / traffic / medical / other
        "status": "جاري المعالجة",  # جاري المعالجة / تم التوجيه / قيد المراجعة
        "location": "حي النرجس، الرياض • قرب شارع عثمان بن عفان",
        "area": "حي النرجس، الرياض",
        "created_at": "منذ ٣ دقائق",
        "received_at": "2025-12-11 22:21",
        "short_description": "المبلّغ أفاد بوجود دخان كثيف وصعوبة خروج السكان من السلم الرئيسي، مع احتمال وجود كبار سن وأطفال داخل المبنى.",
        "agencies": ["الدفاع المدني", "الهلال الأحمر", "التجمع الصحي", "الأمانة", "الدوريات الأمنية"],
        # إحداثيات وهمية فقط لاستخدامها في الخريطة التخيلية
        "map_top": "48%",
        "map_left": "52%",
    },
    {
        "id": "SRJ-1023",
        "title": "حادث مروري بين سيارتين",
        "category": "traffic",
        "status": "تم التوجيه",
        "location": "طريق الملك سلمان، مخرج ٦ • باتجاه الشرق",
        "area": "طريق الملك سلمان - الرياض",
        "created_at": "منذ ٧ دقائق",
        "received_at": "2025-12-11 22:17",
        "short_description": "تصادم بين سيارتين في المسار الأوسط، مع إعاقة جزئية لحركة السير، المبلّغ يرجّح وجود إصابة واحدة على الأقل.",
        "agencies": ["الهلال الأحمر", "الدوريات الأمنية", "الأمانة"],
        "map_top": "28%",
        "map_left": "30%",
    },
    {
        "id": "SRJ-1022",
        "title": "اشتباه حالة طبية حرجة في منزل",
        "category": "medical",
        "status": "قيد المراجعة",
        "location": "حي الياسمين، الرياض • شارع الفرسان",
        "area": "حي الياسمين، الرياض",
        "created_at": "منذ ١٢ دقيقة",
        "received_at": "2025-12-11 22:12",
        "short_description": "المبلّغ ذكر أن المريض لا يستجيب للنداء مع صعوبة في التنفس، العمر التقريبي فوق ٦٠ سنة.",
        "agencies": ["الهلال الأحمر", "التجمع الصحي"],
        "map_top": "68%",
        "map_left": "70%",
    },
]

def find_report(report_id: str):
    for r in REPORTS:
        if r["id"] == report_id:
            return r
    return None

@app.route("/")
def dashboard():
    # اختَر البلاغ المحدد من الـ query string لو موجود، وإلا أول واحد
    selected_id = request.args.get("id")
    if selected_id:
        selected_report = find_report(selected_id)
    else:
        selected_report = REPORTS[0] if REPORTS else None

    return render_template(
        "dashboard.html",
        reports=REPORTS,
        selected_report=selected_report,
    )

# API لاستقبال البلاغات من الـ AI (الخطوة ٣)
@app.route("/api/reports", methods=["POST"])
def api_create_report():
    """
    يستقبل JSON من خدمة الـ AI بالشكل التقريبي التالي:
    {
      "id": "SRJ-1050",
      "title": "حريق في مستودع تجاري",
      "category": "fire",
      "status": "جاري المعالجة",
      "location": "...",
      "area": "...",
      "short_description": "...",
      "agencies": ["الدفاع المدني", "الهلال الأحمر"],
      "map_top": "50%",
      "map_left": "40%"
    }
    """
    data = request.get_json(force=True)

    # لو ما أرسل رقم بلاغ، نولده بشكل بسيط
    if not data.get("id"):
        new_id = f"SRJ-{1024 + len(REPORTS) + 1}"
        data["id"] = new_id

    # إعداد بعض الحقول الافتراضية لو ما جت من الـ AI
    now = datetime.now()
    data.setdefault("status", "جاري المعالجة")
    data.setdefault("created_at", "الآن")
    data.setdefault("received_at", now.strftime("%Y-%m-%d %H:%M"))
    data.setdefault("category", "other")
    data.setdefault("agencies", [])
    data.setdefault("area", data.get("location", "غير محدد"))
    data.setdefault("map_top", "50%")
    data.setdefault("map_left", "50%")

    REPORTS.insert(0, data)  # نخلي الأحدث في الأعلى

    return jsonify({"ok": True, "id": data["id"]}), 201

# API لعرض كل البلاغات بصيغة JSON (ممكن تستخدمه في أي تكامل ثاني)
@app.route("/api/reports", methods=["GET"])
def api_list_reports():
    return jsonify(REPORTS)

if __name__ == "__main__":
    # تشغيل في وضع التطوير
    app.run(host="0.0.0.0", port=5000, debug=True)
