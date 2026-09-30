from __future__ import annotations

import json
import os
import sys
from datetime import date, datetime
from pathlib import Path

from flask import Blueprint, current_app, jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required
from werkzeug.utils import secure_filename

from models.db import execute, query_all, query_one
from utils.authz import role_required

ROOT = Path(__file__).resolve().parents[2]
sys.path.append(str(ROOT / "ai"))
from predict import predict_risk  # noqa: E402

inspections_bp = Blueprint("inspections", __name__)


def _json_ready(row: dict) -> dict:
    out = dict(row)
    for key, value in list(out.items()):
        if hasattr(value, "isoformat"):
            out[key] = value.isoformat()
        elif isinstance(value, bytes):
            out[key] = value.decode()
    if out.get("contributing_factors") and isinstance(out["contributing_factors"], str):
        out["contributing_factors"] = json.loads(out["contributing_factors"])
    return out


def _asset_features(asset: dict, body: dict) -> dict:
    install = asset["installation_date"]
    if isinstance(install, str):
        install = date.fromisoformat(install)
    age = max(1, int((date.today() - install).days / 365))
    prev_insp = query_one(
        "SELECT COUNT(*) AS c FROM inspections WHERE asset_id=%s",
        (asset["id"],),
    )
    prev_maint = query_one(
        "SELECT COUNT(*) AS c FROM maintenance WHERE asset_id=%s",
        (asset["id"],),
    )
    prev_issues = query_one(
        "SELECT COUNT(*) AS c FROM inspections WHERE asset_id=%s AND damage_type <> 'None'",
        (asset["id"],),
    )
    last_insp = query_one(
        """
        SELECT inspection_date FROM inspections
        WHERE asset_id=%s ORDER BY inspection_date DESC, id DESC LIMIT 1
        """,
        (asset["id"],),
    )
    last_maint = query_one(
        """
        SELECT COALESCE(completed_date, scheduled_date, DATE(created_at)) AS d
        FROM maintenance WHERE asset_id=%s
        ORDER BY created_at DESC LIMIT 1
        """,
        (asset["id"],),
    )
    days_insp = 0
    if last_insp and last_insp["inspection_date"]:
        days_insp = (date.today() - last_insp["inspection_date"]).days
    days_maint = 0
    if last_maint and last_maint["d"]:
        days_maint = (date.today() - last_maint["d"]).days
    return {
        "asset_age": age,
        "expected_life": int(asset["expected_life"]),
        "previous_inspections": int(prev_insp["c"]),
        "previous_maintenance": int(prev_maint["c"]),
        "previous_issues": int(prev_issues["c"]),
        "condition": body["condition"],
        "damage_type": body["damage_type"],
        "severity": body["severity"],
        "days_since_inspection": days_insp,
        "days_since_maintenance": days_maint,
    }


@inspections_bp.get("/inspections")
@jwt_required()
def list_inspections():
    rows = query_all(
        """
        SELECT i.*, a.asset_code, a.asset_type, u.name AS inspector_name
        FROM inspections i
        JOIN assets a ON a.id = i.asset_id
        JOIN users u ON u.id = i.inspector_id
        ORDER BY i.created_at DESC
        """
    )
    return jsonify([_json_ready(row) for row in rows])


@inspections_bp.post("/inspections")
@role_required("INSPECTOR", "ADMIN")
def create_inspection():
    payload = request.get_json(silent=True) or {}
    asset_id = request.form.get("asset_id") or payload.get("asset_id")
    condition = request.form.get("condition") or payload.get("condition")
    severity = request.form.get("severity") or payload.get("severity")
    damage_type = request.form.get("damage_type") or payload.get("damage_type")
    remarks = request.form.get("remarks") or payload.get("remarks")
    if not all([asset_id, condition, severity, damage_type]):
        return jsonify({"error": "asset_id, condition, severity, damage_type are required"}), 400

    asset = query_one("SELECT * FROM assets WHERE id=%s", (asset_id,))
    if not asset:
        return jsonify({"error": "Asset not found"}), 404

    image_path = None
    upload = request.files.get("photo")
    if upload and upload.filename:
        filename = secure_filename(f"{asset['asset_code']}_{datetime.now().strftime('%Y%m%d%H%M%S')}_{upload.filename}")
        dest = os.path.join(current_app.config["UPLOAD_FOLDER"], filename)
        upload.save(dest)
        image_path = f"uploads/{filename}"

    inspection_id = execute(
        """
        INSERT INTO inspections (
            asset_id, inspector_id, inspection_date, condition_rating,
            severity, damage_type, remarks, image_path
        ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        """,
        (
            asset_id,
            int(get_jwt_identity()),
            date.today(),
            condition,
            severity,
            damage_type,
            remarks,
            image_path,
        ),
    )

    features = _asset_features(
        asset,
        {"condition": condition, "damage_type": damage_type, "severity": severity},
    )
    try:
        result = predict_risk(features, None)
    except FileNotFoundError as exc:
        return jsonify({"error": str(exc)}), 500

    prediction_id = execute(
        """
        INSERT INTO ai_predictions (
            asset_id, inspection_id, risk_score, risk_level, prediction,
            recommendation, contributing_factors, model_name, model_version
        ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """,
        (
            asset["id"],
            inspection_id,
            result["risk_score"],
            result["risk_level"],
            result["prediction"],
            result["recommendation"],
            json.dumps(result["contributing_factors"]),
            result["model_name"],
            result["model_version"],
        ),
    )

    maintenance_id = None
    if result["risk_level"] == "HIGH":
        maintenance_id = execute(
            """
            INSERT INTO maintenance (
                asset_id, prediction_id, priority, action, status, remarks
            ) VALUES (%s,%s,'HIGH',%s,'PENDING',%s)
            """,
            (
                asset["id"],
                prediction_id,
                "Schedule inspection and maintenance.",
                "Auto-created from HIGH AI risk prediction.",
            ),
        )

    inspection = query_one("SELECT * FROM inspections WHERE id=%s", (inspection_id,))
    prediction = query_one("SELECT * FROM ai_predictions WHERE id=%s", (prediction_id,))
    return jsonify(
        {
            "inspection": _json_ready(inspection),
            "prediction": _json_ready(prediction),
            "probabilities": result["probabilities"],
            "maintenance_id": maintenance_id,
            "alert": result["risk_level"] == "HIGH",
        }
    ), 201


@inspections_bp.get("/predictions")
@jwt_required()
def list_predictions():
    rows = query_all(
        """
        SELECT p.*, a.asset_code, a.asset_type, a.location
        FROM ai_predictions p
        JOIN assets a ON a.id = p.asset_id
        ORDER BY p.prediction_date DESC
        """
    )
    return jsonify([_json_ready(row) for row in rows])
