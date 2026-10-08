# SQLite setup and schema for Courage Quest
import json
import os
import sqlite3
from datetime import date

from werkzeug.security import generate_password_hash

DB_NAME = "courage_quest.db"

DEMO_USERNAME = "demo_cq"
DEMO_PASSWORD = "demo123456"


def get_db_path():
    base = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(base, DB_NAME)


def get_connection():
    conn = sqlite3.connect(get_db_path())
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_connection()
    c = conn.cursor()
    c.execute(
        """CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT,
        birth_date TEXT,
        gender TEXT,
        ocd_type TEXT,
        anxiety_level TEXT,
        compulsive_behaviors TEXT,
        stars INTEGER DEFAULT 0,
        equipped_item TEXT DEFAULT NULL,
        unlocked_items TEXT DEFAULT '[]',
        is_first_login INTEGER DEFAULT 1,
        welcome_gift_received INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )"""
    )
    c.execute(
        """CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        answers TEXT NOT NULL,
        distress_index REAL NOT NULL,
        session_date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )"""
    )
    c.execute(
        """CREATE TABLE IF NOT EXISTS daily_activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        activity_date TEXT NOT NULL,
        stories_count INTEGER DEFAULT 0,
        exercises_count INTEGER DEFAULT 0,
        UNIQUE(user_id, activity_date),
        FOREIGN KEY (user_id) REFERENCES users(id)
    )"""
    )
    conn.commit()
    _seed_demo_user_if_missing(conn)
    conn.close()


def _distress_from_answers(answers):
    total = sum(int(x) for x in answers)
    return round((total / 21.0) * 100.0, 2)


def _seed_demo_user_if_missing(conn):
    """يملأ قاعدة بمستخدم وجلسات تجريبية مرة واحدة (إن لم يكن demo_cq موجوداً)."""
    c = conn.cursor()
    c.execute("SELECT id FROM users WHERE username = ?", (DEMO_USERNAME,))
    if c.fetchone():
        return
    behaviors = ["Hand washing / cleaning", "Repeating phrases"]
    c.execute(
        """INSERT INTO users (
            username, email, password, name, birth_date, gender, ocd_type,
            anxiety_level, compulsive_behaviors, stars, equipped_item,
            unlocked_items, is_first_login, welcome_gift_received
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 1)""",
        (
            DEMO_USERNAME,
            "demo@example.com",
            generate_password_hash(DEMO_PASSWORD),
            "Ahmed Demo",
            "2016-06-15",
            "male",
            "Contamination OCD",
            "Moderate",
            json.dumps(behaviors, ensure_ascii=False),
            50,
            None,
            json.dumps(["wand"], ensure_ascii=False),
        ),
    )
    user_id = c.lastrowid
    demo_sessions = (
        ([2, 1, 3, 2, 1, 0, 2, 3], "2026-05-01"),
        ([1, 2, 2, 3, 2, 1, 1, 2], "2026-05-02"),
    )
    for answers, session_date in demo_sessions:
        distress = _distress_from_answers(answers)
        c.execute(
            "INSERT INTO sessions (user_id, answers, distress_index, session_date) VALUES (?, ?, ?, ?)",
            (
                user_id,
                json.dumps(answers, ensure_ascii=False),
                distress,
                session_date,
            ),
        )
    today = date.today().strftime("%Y-%m-%d")
    c.execute(
        "INSERT OR IGNORE INTO daily_activity (user_id, activity_date, stories_count, exercises_count) VALUES (?, ?, 0, 0)",
        (user_id, today),
    )
    conn.commit()
