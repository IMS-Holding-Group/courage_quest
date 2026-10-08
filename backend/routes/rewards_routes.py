# Rewards unlock and equip API
import json

from flask import Blueprint, jsonify, request

from database import get_connection

rewards_bp = Blueprint("rewards", __name__)

ITEM_PRICES = {"wand": 10, "bow": 20, "crown": 35}


@rewards_bp.route("/unlock", methods=["POST"])
def unlock():
    data = request.get_json() or {}
    user_id = data.get("user_id")
    item = (data.get("item") or "").lower()
    if not user_id or item not in ITEM_PRICES:
        return jsonify({"success": False}), 400
    price = ITEM_PRICES[item]
    conn = get_connection()
    c = conn.cursor()
    c.execute("SELECT stars, unlocked_items FROM users WHERE id = ?", (user_id,))
    row = c.fetchone()
    if row is None:
        conn.close()
        return jsonify({"success": False}), 404
    stars = row["stars"]
    try:
        unlocked = json.loads(row["unlocked_items"] or "[]")
    except json.JSONDecodeError:
        unlocked = []
    if item in unlocked:
        conn.close()
        return jsonify({"success": True, "remaining_stars": stars})
    if stars < price:
        conn.close()
        return jsonify({"success": False, "error": "insufficient"}), 400
    new_stars = stars - price
    unlocked.append(item)
    c.execute(
        "UPDATE users SET stars = ?, unlocked_items = ? WHERE id = ?",
        (new_stars, json.dumps(unlocked, ensure_ascii=False), user_id),
    )
    conn.commit()
    conn.close()
    return jsonify({"success": True, "remaining_stars": new_stars})


@rewards_bp.route("/equip", methods=["POST"])
def equip():
    data = request.get_json() or {}
    user_id = data.get("user_id")
    item = (data.get("item") or "").lower()
    if not user_id or item not in ITEM_PRICES:
        return jsonify({"success": False}), 400
    conn = get_connection()
    c = conn.cursor()
    c.execute("SELECT unlocked_items FROM users WHERE id = ?", (user_id,))
    row = c.fetchone()
    if row is None:
        conn.close()
        return jsonify({"success": False}), 404
    try:
        unlocked = json.loads(row["unlocked_items"] or "[]")
    except json.JSONDecodeError:
        unlocked = []
    if item not in unlocked:
        conn.close()
        return jsonify({"success": False}), 400
    c.execute("UPDATE users SET equipped_item = ? WHERE id = ?", (item, user_id))
    conn.commit()
    conn.close()
    return jsonify({"success": True})


@rewards_bp.route("/<int:user_id>", methods=["GET"])
def rewards_state(user_id):
    conn = get_connection()
    c = conn.cursor()
    c.execute("SELECT stars, unlocked_items, equipped_item FROM users WHERE id = ?", (user_id,))
    row = c.fetchone()
    conn.close()
    if row is None:
        return jsonify({"success": False}), 404
    try:
        unlocked = json.loads(row["unlocked_items"] or "[]")
    except json.JSONDecodeError:
        unlocked = []
    return jsonify(
        {
            "success": True,
            "stars": row["stars"],
            "unlocked_items": unlocked,
            "equipped_item": row["equipped_item"],
        }
    )
