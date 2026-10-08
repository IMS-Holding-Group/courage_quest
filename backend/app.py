import os

from flask import Flask, abort, send_from_directory

from database import init_db
from routes.activity_routes import activity_bp
from routes.auth_routes import auth_bp
from routes.report_routes import report_bp
from routes.rewards_routes import rewards_bp
from routes.session_routes import session_bp
from routes.story_routes import story_bp

app = Flask(__name__)

init_db()

app.register_blueprint(auth_bp, url_prefix="/api/auth")
app.register_blueprint(story_bp, url_prefix="/api/story")
app.register_blueprint(session_bp, url_prefix="/api/session")
app.register_blueprint(report_bp, url_prefix="/api/report")
app.register_blueprint(rewards_bp, url_prefix="/api/rewards")
app.register_blueprint(activity_bp, url_prefix="/api/activity")

STATIC_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "static", "web")


def _under_static_dir(resolved: str) -> bool:
    static_root = os.path.abspath(STATIC_DIR)
    try:
        common = os.path.commonpath([static_root, resolved])
    except ValueError:
        return False
    return os.path.normcase(common) == os.path.normcase(static_root)


@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def serve_spa(path: str):
    """يخدم حزمة Flutter Web؛ مسارات /api/* مسجّلة في الـ blueprints أعلاه."""
    if path.startswith("api"):
        abort(404)
    if path:
        segments = [p for p in path.replace("\\", "/").split("/") if p and p != ".."]
        candidate = os.path.abspath(os.path.join(STATIC_DIR, *segments))
        if not _under_static_dir(candidate) or not os.path.isfile(candidate):
            pass
        else:
            rel = os.path.relpath(candidate, os.path.abspath(STATIC_DIR))
            return send_from_directory(STATIC_DIR, rel)
    index_path = os.path.join(STATIC_DIR, "index.html")
    if not os.path.isfile(index_path):
        abort(
            503,
            description="حزمة الويب غير موجودة. شغّل Build-ForRender.ps1 من جذر المشروع.",
        )
    return send_from_directory(STATIC_DIR, "index.html")


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "5000"))
    app.run(debug=True, host="0.0.0.0", port=port)
