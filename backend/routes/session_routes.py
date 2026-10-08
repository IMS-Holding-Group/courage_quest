# Session save and fetch API
import json
from datetime import date

from flask import Blueprint, jsonify, request

from database import get_connection
from models.session import row_to_session_dict
from services.progress_analyzer import calculate_distress_index

session_bp = Blueprint("session", __name__)


@session_bp.route("/save", methods=["POST"])
def save_session():
    data = request.get_json() or {}
    user_id = data.get("user_id")
    answers = data.get("answers")
    session_date = data.get("date") or date.today().strftime("%Y-%m-%d")
    if not user_id or not isinstance(answers, list) or len(answers) != 8:
        return jsonify({"success": False}), 400
    for a in answers:
        if a not in (0, 1, 2, 3) and a not in (0, 1, 2):
            pass
    distress = calculate_distress_index([int(x) for x in answers])
    conn = get_connection()
    c = conn.cursor()
    c.execute(
        "INSERT INTO sessions (user_id, answers, distress_index, session_date) VALUES (?, ?, ?, ?)",
        (user_id, json.dumps(answers, ensure_ascii=False), distress, session_date),
    )
    c.execute("SELECT id FROM sessions WHERE user_id = ? ORDER BY id DESC", (user_id,))
    ids = [r["id"] for r in c.fetchall()]
    for sid in ids[3:]:
        c.execute("DELETE FROM sessions WHERE id = ?", (sid,))
    c.execute("UPDATE users SET stars = stars + 5 WHERE id = ?", (user_id,))
    c.execute("SELECT stars FROM users WHERE id = ?", (user_id,))
    stars = c.fetchone()["stars"]
    conn.commit()
    conn.close()
    return jsonify({"success": True, "stars_earned": 5, "stars": stars})


@session_bp.route("/<int:user_id>", methods=["GET"])
def list_sessions(user_id):
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
    return jsonify({"sessions": sessions})
