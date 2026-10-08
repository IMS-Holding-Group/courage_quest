# Daily activity: story limit, exercise limit, welcome gift
from datetime import date

from flask import Blueprint, jsonify, request

from database import get_connection

activity_bp = Blueprint("activity", __name__)


def _today_str():
    return date.today().strftime("%Y-%m-%d")


@activity_bp.route("/exercise", methods=["POST"])
def exercise_done():
    data = request.get_json() or {}
    user_id = data.get("user_id")
    if not user_id:
        return jsonify({"success": False}), 400
    conn = get_connection()
    c = conn.cursor()
    today = _today_str()
    c.execute(
        "SELECT exercises_count FROM daily_activity WHERE user_id = ? AND activity_date = ?",
        (user_id, today),
    )
    row = c.fetchone()
    count = row["exercises_count"] if row else 0
    if count >= 3:
        conn.close()
        return jsonify({"success": False, "error": "limit"}), 429
    c.execute(
        "INSERT INTO daily_activity (user_id, activity_date, stories_count, exercises_count) VALUES (?, ?, 0, 1) "
        "ON CONFLICT(user_id, activity_date) DO UPDATE SET exercises_count = daily_activity.exercises_count + 1",
        (user_id, today),
    )
    c.execute("UPDATE users SET stars = stars + 3 WHERE id = ?", (user_id,))
    c.execute("SELECT stars FROM users WHERE id = ?", (user_id,))
    stars = c.fetchone()["stars"]
    conn.commit()
    conn.close()
    return jsonify({"success": True, "stars": stars})


@activity_bp.route("/can_exercise/<int:user_id>", methods=["GET"])
def can_exercise(user_id):
    conn = get_connection()
    c = conn.cursor()
    c.execute(
        "SELECT exercises_count FROM daily_activity WHERE user_id = ? AND activity_date = ?",
        (user_id, _today_str()),
    )
    row = c.fetchone()
    conn.close()
    count = row["exercises_count"] if row else 0
    return jsonify({"can_exercise": count < 3, "remaining": max(0, 3 - count)})


@activity_bp.route("/gift", methods=["POST"])
def welcome_gift():
    data = request.get_json() or {}
    user_id = data.get("user_id")
    if not user_id:
        return jsonify({"success": False}), 400
    conn = get_connection()
    c = conn.cursor()
    c.execute("SELECT welcome_gift_received, stars FROM users WHERE id = ?", (user_id,))
    row = c.fetchone()
    if row is None:
        conn.close()
        return jsonify({"success": False}), 404
    if row["welcome_gift_received"]:
        conn.close()
        return jsonify({"success": True, "stars": row["stars"], "already": True})
    c.execute(
        "UPDATE users SET stars = stars + 3, welcome_gift_received = 1 WHERE id = ?",
        (user_id,),
    )
    c.execute("SELECT stars FROM users WHERE id = ?", (user_id,))
    stars = c.fetchone()["stars"]
    conn.commit()
    conn.close()
    return jsonify({"success": True, "stars": stars})
