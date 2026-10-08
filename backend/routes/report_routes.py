# Progress report API (sklearn RandomForest via ml.predictor)
from flask import Blueprint, jsonify

from database import get_connection
from ml.predictor import predict_progress
from models.session import row_to_session_dict

report_bp = Blueprint("report", __name__)

_AR_TO_EN = {"تحسن": "Improving", "مستقر": "Stable", "تدهور": "Worsening"}


def _predictions_en(pred):
    out = {}
    for k, v in pred.items():
        s = str(v).strip()
        out[k] = _AR_TO_EN.get(s, v)
    return out


@report_bp.route("/<int:user_id>", methods=["GET"])
def report(user_id):
    conn = get_connection()
    c = conn.cursor()
    c.execute(
        "SELECT * FROM sessions WHERE user_id = ? ORDER BY id DESC LIMIT 3",
        (user_id,),
    )
    rows = list(reversed(c.fetchall()))
    conn.close()
    sessions = []
    for row in rows:
        s = row_to_session_dict(row)
        sessions.append(
            {
                "answers": s["answers"],
                "distress_index": s["distress_index"],
                "session_date": s["session_date"],
            }
        )
    if len(sessions) < 2:
        return jsonify({"error": "Not enough sessions for analysis"}), 400

    session_answers = []
    for s in sessions:
        session_answers.append([int(x) for x in s["answers"]])
    while len(session_answers) < 3:
        session_answers.insert(0, list(session_answers[0]))

    predictions = _predictions_en(predict_progress(session_answers))
    chart_data = [{"date": s["session_date"], "distress": s["distress_index"]} for s in sessions]

    return jsonify(
        {
            "bravery_progress": predictions["bravery_progress"],
            "emotional_wellbeing": predictions["emotional_wellbeing"],
            "growth_mindset": predictions["growth_mindset"],
            "facing_fears": predictions["facing_fears"],
            "coping_skills": predictions["coping_skills"],
            "sessions": sessions,
            "sessions_chart": chart_data,
            "sessions_count": len(sessions),
        }
    )
