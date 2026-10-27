from flask import Blueprint, jsonify, request, current_app
from werkzeug.utils import secure_filename
from utils.helpers import run_query, run_write, allowed_file
import os

api_bp = Blueprint("api", __name__)


@api_bp.route("/notes", methods=["GET"])
def get_notes():
    notes = run_query(
        "SELECT id, title, body, filename, created_at FROM notes ORDER BY created_at DESC"
    )
    # created_at may be a datetime on PostgreSQL; make it JSON-safe.
    for note in notes:
        if note.get("created_at") is not None:
            note["created_at"] = str(note["created_at"])
    return jsonify(notes)


@api_bp.route("/notes", methods=["POST"])
def create_note():
    title = request.form.get("title", "Untitled Note")
    body = request.form.get("body", "")
    filename = None

    uploaded_file = request.files.get("attachment")
    if uploaded_file and uploaded_file.filename and allowed_file(uploaded_file.filename):
        filename = secure_filename(uploaded_file.filename)
        destination = os.path.join(current_app.config["UPLOAD_FOLDER"], filename)
        uploaded_file.save(destination)

    note_id = run_write(
        "INSERT INTO notes (title, body, filename) VALUES (?, ?, ?)",
        (title, body, filename),
        returning_id=True,
    )
    return jsonify({"id": note_id, "title": title, "body": body, "filename": filename}), 201


@api_bp.route("/notes/<int:note_id>", methods=["GET"])
def get_note(note_id):
    note = run_query(
        "SELECT id, title, body, filename, created_at FROM notes WHERE id = ?",
        (note_id,),
        one=True,
    )
    if note is None:
        return jsonify({"error": "Note not found"}), 404
    if note.get("created_at") is not None:
        note["created_at"] = str(note["created_at"])
    return jsonify(note)


@api_bp.route("/notes/<int:note_id>", methods=["DELETE"])
def delete_note(note_id):
    deleted = run_write("DELETE FROM notes WHERE id = ?", (note_id,))
    if deleted == 0:
        return jsonify({"error": "Note not found"}), 404
    return jsonify({"message": "Note deleted"}), 200
