from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required

from models.db import execute, query_all, query_one
from utils.authz import role_required

maintenance_bp = Blueprint("maintenance", __name__)


def _ready(row: dict) -> dict:
    out = dict(row)
    for key, value in list(out.items()):
        if hasattr(value, "isoformat"):
            out[key] = value.isoformat()
    return out


@maintenance_bp.get("")
@jwt_required()
def list_jobs():
    rows = query_all(
        """
        SELECT m.*, a.asset_code, a.asset_type, a.location,
               p.risk_score, p.risk_level, u.name AS assignee_name
        FROM maintenance m
        JOIN assets a ON a.id = m.asset_id
        LEFT JOIN ai_predictions p ON p.id = m.prediction_id
        LEFT JOIN users u ON u.id = m.assigned_to
        ORDER BY FIELD(m.status,'PENDING','ASSIGNED','IN_PROGRESS','COMPLETED'),
                 FIELD(m.priority,'HIGH','MEDIUM','LOW'), m.created_at DESC
        """
    )
    return jsonify([_ready(row) for row in rows])


@maintenance_bp.post("")
@role_required("MAINTENANCE", "ADMIN")
def create_job():
    body = request.get_json(silent=True) or {}
    if not body.get("asset_id"):
        return jsonify({"error": "asset_id is required"}), 400
    job_id = execute(
        """
        INSERT INTO maintenance (
            asset_id, prediction_id, assigned_to, priority, action,
            scheduled_date, status, remarks
        ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        """,
        (
            body["asset_id"],
            body.get("prediction_id"),
            body.get("assigned_to"),
            body.get("priority") or "MEDIUM",
            body.get("action"),
            body.get("scheduled_date"),
            "ASSIGNED" if body.get("assigned_to") else "PENDING",
            body.get("remarks"),
        ),
    )
    return jsonify(_ready(query_one("SELECT * FROM maintenance WHERE id=%s", (job_id,)))), 201


@maintenance_bp.put("/<int:job_id>")
@role_required("MAINTENANCE", "ADMIN")
def update_job(job_id: int):
    job = query_one("SELECT * FROM maintenance WHERE id=%s", (job_id,))
    if not job:
        return jsonify({"error": "Maintenance record not found"}), 404
    body = request.get_json(silent=True) or {}
    status = body.get("status") or job["status"]
    assigned_to = body.get("assigned_to", job["assigned_to"])
    if status == "ASSIGNED" and not assigned_to:
        return jsonify({"error": "assigned_to is required when assigning"}), 400
    completed = body.get("completed_date") or job["completed_date"]
    if status == "COMPLETED" and not completed:
        from datetime import date

        completed = date.today()
    execute(
        """
        UPDATE maintenance SET
            assigned_to=%s, priority=%s, action=%s, scheduled_date=%s,
            completed_date=%s, status=%s, remarks=%s
        WHERE id=%s
        """,
        (
            assigned_to,
            body.get("priority") or job["priority"],
            body.get("action") or job["action"],
            body.get("scheduled_date") or job["scheduled_date"],
            completed,
            status,
            body.get("remarks") if "remarks" in body else job["remarks"],
            job_id,
        ),
    )
    return jsonify(_ready(query_one(
        """
        SELECT m.*, a.asset_code, a.asset_type, a.location, u.name AS assignee_name
        FROM maintenance m
        JOIN assets a ON a.id = m.asset_id
        LEFT JOIN users u ON u.id = m.assigned_to
        WHERE m.id=%s
        """,
        (job_id,),
    )))
