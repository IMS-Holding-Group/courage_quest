# Story generation API
from datetime import date

from flask import Blueprint, jsonify, request

from database import get_connection
from models.user import row_to_user_dict
from services.story_generator import generate_story

story_bp = Blueprint("story", __name__)


def _today_str():
    return date.today().strftime("%Y-%m-%d")


@story_bp.route("/can_generate/<int:user_id>", methods=["GET"])
def can_generate(user_id):
    conn = get_connection()
    c = conn.cursor()
    c.execute(
        "SELECT stories_count FROM daily_activity WHERE user_id = ? AND activity_date = ?",
        (user_id, _today_str()),
    )
    row = c.fetchone()
    conn.close()
    count = row["stories_count"] if row else 0
    return jsonify({"can_generate": count < 1})


@story_bp.route("/generate", methods=["POST"])
def generate():
    data = request.get_json() or {}
    user_id = data.get("user_id")
    if not user_id:
        return jsonify({"success": False}), 400
    conn = get_connection()
    c = conn.cursor()
    today = _today_str()
    c.execute(
        "SELECT stories_count FROM daily_activity WHERE user_id = ? AND activity_date = ?",
        (user_id, today),
    )
    row = c.fetchone()
    if row and row["stories_count"] >= 1:
        conn.close()
        return jsonify({"success": False, "error": "daily_limit"}), 429
    c.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    urow = c.fetchone()
    if urow is None:
        conn.close()
        return jsonify({"success": False}), 404
    user = row_to_user_dict(urow)
    user["age"] = _age_from_birth(user.get("birth_date") or "2015-01-01")
    story = generate_story(user)
    c.execute(
        "INSERT INTO daily_activity (user_id, activity_date, stories_count, exercises_count) VALUES (?, ?, 1, 0) "
        "ON CONFLICT(user_id, activity_date) DO UPDATE SET stories_count = daily_activity.stories_count + 1",
        (user_id, today),
    )
    conn.commit()
    conn.close()
    audio_url = ""
    return jsonify(
        {
            "success": True,
            "story_pages": story["story_pages"],
            "audio_url": audio_url,
            "images": story.get("images", []),
        }
    )


def _age_from_birth(birth_date_str):
    from datetime import datetime

    try:
        bd = datetime.strptime(birth_date_str, "%Y-%m-%d").date()
        t = date.today()
        age = t.year - bd.year - ((t.month, t.day) < (bd.month, bd.day))
        return max(7, min(10, age))
    except Exception:
        return 8
