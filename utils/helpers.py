"""Database helpers for CloudNotes.

Supports both SQLite (local dev default) and PostgreSQL (deployment target),
selected by the DATABASE_URL environment variable:

  - unset or "sqlite:///..."   -> SQLite   (file-based, dev only)
  - "postgresql://user:pw@host:port/db" -> PostgreSQL (production)

The rest of the app talks to this module through get_db_connection() and
run_query()/run_write(), so the route code does not care which engine is used.
"""
import os
import sqlite3
from urllib.parse import urlparse

# psycopg (v3) is only needed when PostgreSQL is used. Import lazily so the app
# still runs on plain SQLite without the driver installed.
try:
    import psycopg
    from psycopg.rows import dict_row
    _HAS_PSYCOPG = True
except ImportError:  # pragma: no cover
    _HAS_PSYCOPG = False


def _database_url():
    return os.environ.get("DATABASE_URL", "").strip()


def is_postgres():
    """True when the app is configured to use PostgreSQL."""
    url = _database_url()
    return url.startswith("postgres://") or url.startswith("postgresql://")


# Schema per engine. PostgreSQL uses SERIAL + TIMESTAMP; SQLite uses AUTOINCREMENT.
_SCHEMA_SQLITE = """
CREATE TABLE IF NOT EXISTS notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    filename TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
"""

_SCHEMA_POSTGRES = """
CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    filename TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"""

ALLOWED_EXTENSIONS = {"txt", "md", "pdf", "png", "jpg", "jpeg", "gif"}


def get_db_connection(sqlite_path=None):
    """Return a DB connection whose rows behave like dicts.

    For PostgreSQL the connection is opened from DATABASE_URL. For SQLite it
    uses sqlite_path (falling back to the DATABASE_PATH env var).
    """
    if is_postgres():
        if not _HAS_PSYCOPG:
            raise RuntimeError(
                "DATABASE_URL points at PostgreSQL but the 'psycopg' driver "
                "is not installed. Run: pip install 'psycopg[binary]'"
            )
        return psycopg.connect(_database_url(), row_factory=dict_row)

    path = sqlite_path or os.environ.get("DATABASE_PATH", "database/cloudnotes.db")
    conn = sqlite3.connect(path)
    conn.row_factory = sqlite3.Row
    return conn


def _adapt(sql):
    """SQLite uses '?' placeholders, PostgreSQL uses '%s'. Author queries with
    '?' everywhere and translate here so one query string works on both."""
    if is_postgres():
        return sql.replace("?", "%s")
    return sql


def init_db(sqlite_path=None):
    """Create the notes table if it does not exist, on whichever engine is active."""
    conn = get_db_connection(sqlite_path)
    try:
        if is_postgres():
            with conn.cursor() as cur:
                cur.execute(_SCHEMA_POSTGRES)
            conn.commit()
        else:
            os.makedirs(os.path.dirname(sqlite_path or "database/cloudnotes.db"), exist_ok=True)
            with conn:
                conn.executescript(_SCHEMA_SQLITE)
    finally:
        conn.close()


def run_query(sql, params=(), one=False):
    """Run a SELECT and return a list of dict rows (or a single dict if one=True)."""
    conn = get_db_connection()
    try:
        if is_postgres():
            with conn.cursor() as cur:
                cur.execute(_adapt(sql), params)
                rows = cur.fetchall()
        else:
            cur = conn.execute(_adapt(sql), params)
            rows = [dict(r) for r in cur.fetchall()]
    finally:
        conn.close()
    if one:
        return rows[0] if rows else None
    return rows


def run_write(sql, params=(), returning_id=False):
    """Run an INSERT/UPDATE/DELETE. Returns the new row id (INSERT) or the number
    of affected rows. Works on both engines."""
    conn = get_db_connection()
    try:
        if is_postgres():
            with conn.cursor() as cur:
                if returning_id:
                    cur.execute(_adapt(sql) + " RETURNING id", params)
                    new_id = cur.fetchone()["id"]
                    conn.commit()
                    return new_id
                cur.execute(_adapt(sql), params)
                affected = cur.rowcount
                conn.commit()
                return affected
        else:
            cur = conn.cursor()
            cur.execute(_adapt(sql), params)
            conn.commit()
            return cur.lastrowid if returning_id else cur.rowcount
    finally:
        conn.close()


def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS
