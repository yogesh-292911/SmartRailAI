from datetime import timedelta

from flask import Blueprint, jsonify, request
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required
from werkzeug.security import check_password_hash

from models.db import query_one

auth_bp = Blueprint("auth", __name__)


def serialize_user(user: dict) -> dict:
    return {
        "id": user["id"],
        "employee_id": user["employee_id"],
        "name": user["name"],
        "email": user["email"],
        "role": user["role"],
    }


@auth_bp.post("/login")
def login():
    body = request.get_json(silent=True) or {}
    employee_id = (body.get("employee_id") or "").strip()
    password = body.get("password") or ""
    if not employee_id or not password:
        return jsonify({"error": "Employee ID and password are required"}), 400

    user = query_one("SELECT * FROM users WHERE employee_id=%s", (employee_id,))
    if not user or not check_password_hash(user["password_hash"], password):
        return jsonify({"error": "Invalid employee ID or password"}), 401

    token = create_access_token(
        identity=str(user["id"]),
        additional_claims={"role": user["role"], "name": user["name"]},
        expires_delta=timedelta(days=7),
    )
    return jsonify({"token": token, "user": serialize_user(user)})


@auth_bp.get("/me")
@jwt_required()
def me():
    user = query_one("SELECT * FROM users WHERE id=%s", (get_jwt_identity(),))
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify(serialize_user(user))
