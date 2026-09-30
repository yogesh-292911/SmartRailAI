import json
from datetime import date

from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required

from models.db import execute, query_all, query_one
from utils.authz import role_required

assets_bp = Blueprint("assets", __name__)


def attach_latest(asset: dict) -> dict:
    latest_insp = query_one(
        """
        SELECT inspection_date, condition_rating
        FROM inspections WHERE asset_id=%s
        ORDER BY inspection_date DESC, id DESC LIMIT 1
        """,
        (asset["id"],),
    )
    latest_pred = query_one(
        """
        SELECT risk_score, risk_level, prediction, recommendation,
               contributing_factors, prediction_date
        FROM ai_predictions WHERE asset_id=%s
        ORDER BY prediction_date DESC, id DESC LIMIT 1
        """,
        (asset["id"],),
    )
    qr = query_one(
        "SELECT qr_code, status FROM qr_codes WHERE asset_id=%s AND status='ACTIVE' LIMIT 1",
        (asset["id"],),
    )
    asset["last_inspection"] = latest_insp["inspection_date"].isoformat() if latest_insp else None
    asset["condition"] = latest_insp["condition_rating"] if latest_insp else "Unknown"
    asset["ai_risk_score"] = float(latest_pred["risk_score"]) if latest_pred else None
    asset["ai_risk_level"] = latest_pred["risk_level"] if latest_pred else None
    if latest_pred:
        factors = latest_pred.get("contributing_factors")
        if isinstance(factors, str):
            latest_pred["contributing_factors"] = json.loads(factors)
        if latest_pred.get("prediction_date"):
            latest_pred["prediction_date"] = latest_pred["prediction_date"].isoformat()
        latest_pred["risk_score"] = float(latest_pred["risk_score"])
        asset["latest_prediction"] = latest_pred
    else:
        asset["latest_prediction"] = None
    asset["qr_code"] = qr["qr_code"] if qr else asset["asset_code"]
    if asset.get("installation_date"):
        asset["installation_date"] = asset["installation_date"].isoformat()
    if asset.get("created_at"):
        asset["created_at"] = asset["created_at"].isoformat()
    if asset.get("updated_at"):
        asset["updated_at"] = asset["updated_at"].isoformat()
    return asset


@assets_bp.get("")
@jwt_required()
def list_assets():
    rows = query_all("SELECT * FROM assets ORDER BY asset_code")
    return jsonify([attach_latest(row) for row in rows])


@assets_bp.get("/code/<asset_code>")
@jwt_required()
def get_by_code(asset_code: str):
    asset = query_one("SELECT * FROM assets WHERE asset_code=%s", (asset_code.strip(),))
    if not asset:
        return jsonify({"error": "Asset not found for this QR code"}), 404
    return jsonify(attach_latest(asset))


@assets_bp.get("/<int:asset_id>")
@jwt_required()
def get_asset(asset_id: int):
    asset = query_one("SELECT * FROM assets WHERE id=%s", (asset_id,))
    if not asset:
        return jsonify({"error": "Asset not found"}), 404
    return jsonify(attach_latest(asset))


@assets_bp.post("")
@role_required("ADMIN")
def create_asset():
    body = request.get_json(silent=True) or {}
    required = ["asset_code", "asset_type", "railway_zone", "location", "installation_date"]
    missing = [key for key in required if not body.get(key)]
    if missing:
        return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400
    if query_one("SELECT id FROM assets WHERE asset_code=%s", (body["asset_code"],)):
        return jsonify({"error": "Asset code already exists"}), 409
    asset_id = execute(
        """
        INSERT INTO assets (
            asset_code, asset_type, railway_zone, section, location,
            manufacturer, installation_date, expected_life, status, description
        ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """,
        (
            body["asset_code"].strip(),
            body["asset_type"],
            body["railway_zone"],
            body.get("section"),
            body["location"],
            body.get("manufacturer"),
            body["installation_date"],
            int(body.get("expected_life") or 20),
            body.get("status") or "ACTIVE",
            body.get("description"),
        ),
    )
    execute(
        """
        INSERT INTO qr_codes (asset_id, qr_code, generated_date, status)
        VALUES (%s, %s, %s, 'ACTIVE')
        """,
        (asset_id, body["asset_code"].strip(), date.today()),
    )
    asset = query_one("SELECT * FROM assets WHERE id=%s", (asset_id,))
    return jsonify(attach_latest(asset)), 201


@assets_bp.put("/<int:asset_id>")
@role_required("ADMIN")
def update_asset(asset_id: int):
    if not query_one("SELECT id FROM assets WHERE id=%s", (asset_id,)):
        return jsonify({"error": "Asset not found"}), 404
    body = request.get_json(silent=True) or {}
    execute(
        """
        UPDATE assets SET
            asset_type=%s, railway_zone=%s, section=%s, location=%s,
            manufacturer=%s, installation_date=%s, expected_life=%s,
            status=%s, description=%s
        WHERE id=%s
        """,
        (
            body.get("asset_type"),
            body.get("railway_zone"),
            body.get("section"),
            body.get("location"),
            body.get("manufacturer"),
            body.get("installation_date"),
            int(body.get("expected_life") or 20),
            body.get("status") or "ACTIVE",
            body.get("description"),
            asset_id,
        ),
    )
    return jsonify(attach_latest(query_one("SELECT * FROM assets WHERE id=%s", (asset_id,))))


@assets_bp.delete("/<int:asset_id>")
@role_required("ADMIN")
def delete_asset(asset_id: int):
    if not query_one("SELECT id FROM assets WHERE id=%s", (asset_id,)):
        return jsonify({"error": "Asset not found"}), 404
    execute("DELETE FROM assets WHERE id=%s", (asset_id,))
    return jsonify({"ok": True})


@assets_bp.post("/<int:asset_id>/qr")
@role_required("ADMIN")
def regenerate_qr(asset_id: int):
    asset = query_one("SELECT * FROM assets WHERE id=%s", (asset_id,))
    if not asset:
        return jsonify({"error": "Asset not found"}), 404
    execute("UPDATE qr_codes SET status='INACTIVE' WHERE asset_id=%s", (asset_id,))
    execute(
        """
        INSERT INTO qr_codes (asset_id, qr_code, generated_date, status)
        VALUES (%s, %s, %s, 'ACTIVE')
        """,
        (asset_id, asset["asset_code"], date.today()),
    )
    return jsonify({"qr_code": asset["asset_code"], "asset_id": asset_id})


@assets_bp.get("/<int:asset_id>/history")
@jwt_required()
def history(asset_id: int):
    asset = query_one("SELECT * FROM assets WHERE id=%s", (asset_id,))
    if not asset:
        return jsonify({"error": "Asset not found"}), 404
    events = [
        {
            "date": asset["installation_date"].isoformat(),
            "title": "Asset Installed",
            "detail": asset["asset_type"],
            "kind": "install",
        }
    ]
    for row in query_all(
        """
        SELECT inspection_date, condition_rating, damage_type, severity
        FROM inspections WHERE asset_id=%s ORDER BY inspection_date, id
        """,
        (asset_id,),
    ):
        events.append(
            {
                "date": row["inspection_date"].isoformat(),
                "title": "Inspection",
                "detail": f"Condition: {row['condition_rating']} · {row['damage_type']} ({row['severity']})",
                "kind": "inspection",
            }
        )
    for row in query_all(
        """
        SELECT prediction_date, risk_score, risk_level
        FROM ai_predictions WHERE asset_id=%s ORDER BY prediction_date, id
        """,
        (asset_id,),
    ):
        events.append(
            {
                "date": row["prediction_date"].date().isoformat(),
                "title": "AI Prediction",
                "detail": f"Risk: {row['risk_score']}% {row['risk_level']}",
                "kind": "ai",
            }
        )
    for row in query_all(
        """
        SELECT scheduled_date, completed_date, status, action, created_at
        FROM maintenance WHERE asset_id=%s ORDER BY created_at, id
        """,
        (asset_id,),
    ):
        when = (row["completed_date"] or row["scheduled_date"] or row["created_at"].date())
        events.append(
            {
                "date": when.isoformat() if hasattr(when, "isoformat") else str(when),
                "title": "Maintenance",
                "detail": f"{row['action'] or 'Maintenance'} · Status: {row['status']}",
                "kind": "maintenance",
            }
        )
    events.sort(key=lambda item: item["date"])
    return jsonify(events)
