"""CloudNotes application entry point.

Configuration is read from environment variables (see .env.example), not
hard-coded, so the same code runs locally on SQLite and in deployment on
PostgreSQL. Create the app with create_app(); gunicorn uses the module-level
`app` object (gunicorn --bind 0.0.0.0:5000 app:app).
"""
import os
from flask import Flask, render_template, send_from_directory
from dotenv import load_dotenv

from api.routes import api_bp
from utils.helpers import init_db

# Load variables from a local .env file if present (no-op in production where
# the environment is set by the service manager / instance metadata).
load_dotenv()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))


def create_app():
    app = Flask(__name__)

    # --- Configuration from environment (with safe local defaults) ---
    app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "dev-insecure-change-me")
    app.config["UPLOAD_FOLDER"] = os.environ.get(
        "UPLOAD_FOLDER", os.path.join(BASE_DIR, "uploads")
    )
    # For SQLite only; PostgreSQL deployments set DATABASE_URL instead.
    app.config["DATABASE_PATH"] = os.environ.get(
        "DATABASE_PATH", os.path.join(BASE_DIR, "database", "cloudnotes.db")
    )
    app.config["MAX_CONTENT_LENGTH"] = int(
        os.environ.get("MAX_CONTENT_LENGTH", 5 * 1024 * 1024)
    )

    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

    app.register_blueprint(api_bp, url_prefix="/api")

    # Ensure the schema exists on whichever database engine is configured.
    # Runs once at startup, so it works under gunicorn too (Flask 2.3 removed
    # before_first_request).
    with app.app_context():
        init_db(app.config["DATABASE_PATH"])

    @app.route("/")
    def home():
        return render_template("index.html")

    @app.route("/notes")
    def notes_page():
        return render_template("notes.html")

    @app.route("/health")
    def health():
        return {"status": "healthy"}

    @app.route("/uploads/<path:filename>")
    def uploaded_file(filename):
        return send_from_directory(app.config["UPLOAD_FOLDER"], filename)

    return app


# gunicorn entry point: `gunicorn --bind 0.0.0.0:5000 app:app`
app = create_app()


if __name__ == "__main__":
    host = os.environ.get("HOST", "0.0.0.0")
    port = int(os.environ.get("PORT", 5000))
    # debug off by default in deployment; set FLASK_DEBUG=1 locally if needed.
    debug = os.environ.get("FLASK_DEBUG", "0") == "1"
    app.run(host=host, port=port, debug=debug)
