# Authentication API routes
import json
from datetime import date, datetime

from flask import Blueprint, jsonify, request
from werkzeug.security import check_password_hash, generate_password_hash

from database import get_connection
from models.user import row_to_user_dict

auth_bp = Blueprint("auth", __name__)


def _age_from_birth(birth_date_str):
    try:
        bd = datetime.strptime(birth_date_str, "%Y-%m-%d").date()
        today = date.today()
        age = today.year - bd.year - ((today.month, today.day) < (bd.month, bd.day))
        return max(7, min(10, age))
    except Exception:
        return 8


@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.get_json() or {}
    required = [
        "username",
        "email",
        "password",
        "name",
        "birth_date",
        "gender",
        "ocd_type",
        "anxiety_level",
        "compulsive_behaviors",
    ]
    for field in required:
        if field not in data or data[field] in (None, "", []):
            return jsonify({"success": False, "error": "Missing required field"}), 400
    conn = get_connection()
    c = conn.cursor()
    pw_hash = generate_password_hash(data["password"])
    behaviors_json = json.dumps(data["compulsive_behaviors"], ensure_ascii=False)
    try:
        c.execute(
            """INSERT INTO users (username, email, password, name, birth_date, gender, ocd_type, anxiety_level, compulsive_behaviors)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                data["username"],
                data["email"],
                pw_hash,
                data["name"],
                data["birth_date"],
                data["gender"],
                data["ocd_type"],
                data["anxiety_level"],
                behaviors_json,
            ),
        )
        conn.commit()
        user_id = c.lastrowid
    except Exception as e:
        conn.close()
        if "UNIQUE" in str(e).upper():
            return jsonify({"success": False, "error": "Username or email already taken"}), 400
        return jsonify({"success": False, "error": str(e)}), 400
    conn.close()
    return jsonify({"success": True, "user_id": user_id})


@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.get_json() or {}
    username = (data.get("username") or "").strip()
    password = data.get("password") or ""
    if not username or not password:
        return jsonify({"success": False, "error": "Username and password are required"}), 400
    conn = get_connection()
    c = conn.cursor()
    c.execute("SELECT * FROM users WHERE username = ?", (username,))
    row = c.fetchone()
    if row is None or not check_password_hash(row["password"], password):
        conn.close()
        return jsonify({"success": False, "error": "Invalid username or password"}), 401
    user = dict(row)
    is_first = int(user.get("is_first_login") or 0)
    if is_first:
        c.execute("UPDATE users SET is_first_login = 0 WHERE id = ?", (user["id"],))
    conn.commit()
    conn.close()
    return jsonify(
        {
            "success": True,
            "user_id": user["id"],
            "gender": user.get("gender") or "male",
            "is_first_login": bool(is_first),
        }
    )


@auth_bp.route("/update", methods=["PUT"])
def update_user():
    data = request.get_json() or {}
    user_id = data.get("user_id")
    if not user_id:
        return jsonify({"success": False}), 400
    conn = get_connection()
    c = conn.cursor()
    c.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    row = c.fetchone()
    if row is None:
        conn.close()
        return jsonify({"success": False}), 404
    email = data.get("email")
    password = data.get("password")
    if email:
        c.execute("UPDATE users SET email = ? WHERE id = ?", (email, user_id))
    if password:
        c.execute(
            "UPDATE users SET password = ? WHERE id = ?",
            (generate_password_hash(password), user_id),
        )
    conn.commit()
    conn.close()
    return jsonify({"success": True})


@auth_bp.route("/user/<int:user_id>", methods=["GET"])
def get_user(user_id):
    conn = get_connection()
    c = conn.cursor()
    c.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    row = c.fetchone()
    conn.close()
    if row is None:
        return jsonify({"success": False}), 404
    u = row_to_user_dict(row)
    u.pop("password", None)
    u["age"] = _age_from_birth(u.get("birth_date") or "2015-01-01")
    return jsonify({"success": True, "user": u})
