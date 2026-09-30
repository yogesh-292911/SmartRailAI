from flask import Blueprint, jsonify, request
from werkzeug.security import generate_password_hash

from models.db import execute, query_all, query_one
from utils.authz import role_required

users_bp = Blueprint("users", __name__)


@users_bp.get("")
@role_required("ADMIN")
def list_users():
    rows = query_all(
        "SELECT id, employee_id, name, email, role, created_at FROM users ORDER BY id"
    )
    for row in rows:
        if row.get("created_at"):
            row["created_at"] = row["created_at"].isoformat()
    return jsonify(rows)


@users_bp.post("")
@role_required("ADMIN")
def create_user():
    body = request.get_json(silent=True) or {}
    required = ["employee_id", "name", "email", "password", "role"]
    if any(not body.get(key) for key in required):
        return jsonify({"error": "employee_id, name, email, password, role are required"}), 400
    if body["role"] not in {"ADMIN", "INSPECTOR", "MAINTENANCE"}:
        return jsonify({"error": "Invalid role"}), 400
    if query_one("SELECT id FROM users WHERE employee_id=%s OR email=%s", (body["employee_id"], body["email"])):
        return jsonify({"error": "Employee ID or email already exists"}), 409
    user_id = execute(
        """
        INSERT INTO users (employee_id, name, email, password_hash, role)
        VALUES (%s,%s,%s,%s,%s)
        """,
        (
            body["employee_id"].strip(),
            body["name"],
            body["email"],
            generate_password_hash(body["password"]),
            body["role"],
        ),
    )
    user = query_one(
        "SELECT id, employee_id, name, email, role, created_at FROM users WHERE id=%s",
        (user_id,),
    )
    user["created_at"] = user["created_at"].isoformat()
    return jsonify(user), 201
