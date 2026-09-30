"""Load the trained Random Forest bundle and score one inspection."""

from __future__ import annotations

from pathlib import Path

import joblib
import pandas as pd

from generate_dataset import DAMAGE_TYPES, CONDITIONS, SEVERITIES

AI_DIR = Path(__file__).resolve().parent
MODEL_PATH = AI_DIR / "model.pkl"

FACTOR_GROUPS = {
    "Damage Severity": ["severity_enc", "damage_enc", "condition_enc"],
    "Previous Issues": ["previous_issues", "previous_inspections"],
    "Asset Age": ["asset_age", "expected_life"],
    "Inspection Gap": ["days_since_inspection"],
    "Maintenance History": ["previous_maintenance", "days_since_maintenance"],
}

RECOMMENDATIONS = {
    "LOW": "Continue routine inspection. No urgent maintenance required.",
    "MEDIUM": "Schedule a follow-up inspection and monitor this asset closely.",
    "HIGH": "Schedule inspection and maintenance. Treat as high priority.",
}


def encode_condition(value: str) -> int:
    return CONDITIONS.index(value) if value in CONDITIONS else 1


def encode_damage(value: str) -> int:
    return DAMAGE_TYPES.index(value) if value in DAMAGE_TYPES else DAMAGE_TYPES.index("Other")


def encode_severity(value: str) -> int:
    return SEVERITIES.index(value) if value in SEVERITIES else 1


def load_bundle(model_path: Path | None = None) -> dict:
    path = model_path or MODEL_PATH
    if not path.exists():
        raise FileNotFoundError(f"Model not found at {path}. Run train_model.py first.")
    return joblib.load(path)


def contributing_factors(bundle: dict, features: dict) -> list[dict]:
    importances = bundle["feature_importances"]
    grouped: dict[str, float] = {}
    for group, names in FACTOR_GROUPS.items():
        grouped[group] = sum(importances.get(name, 0.0) for name in names)
        # Weight slightly by the current row so the bars are not identical every time.
        magnitude = 0.0
        for name in names:
            magnitude += abs(float(features.get(name, 0)))
        grouped[group] *= 1.0 + min(magnitude / 50.0, 1.5)
    total = sum(grouped.values()) or 1.0
    items = [
        {"name": name, "percent": round(value / total * 100, 1)}
        for name, value in grouped.items()
    ]
    items.sort(key=lambda item: item["percent"], reverse=True)
    return items


def predict_risk(payload: dict, bundle: dict | None = None) -> dict:
    bundle = bundle or load_bundle()
    features = {
        "asset_age": int(payload["asset_age"]),
        "expected_life": int(payload["expected_life"]),
        "previous_inspections": int(payload["previous_inspections"]),
        "previous_maintenance": int(payload["previous_maintenance"]),
        "previous_issues": int(payload["previous_issues"]),
        "condition_enc": encode_condition(payload["condition"]),
        "damage_enc": encode_damage(payload["damage_type"]),
        "severity_enc": encode_severity(payload["severity"]),
        "days_since_inspection": int(payload.get("days_since_inspection", 0)),
        "days_since_maintenance": int(payload.get("days_since_maintenance", 0)),
    }
    frame = pd.DataFrame([features], columns=bundle["features"])
    model = bundle["model"]
    label = str(model.predict(frame)[0])
    proba = model.predict_proba(frame)[0]
    class_index = {name: i for i, name in enumerate(model.classes_)}
    probabilities = {
        cls: round(float(proba[class_index[cls]] * 100), 2)
        for cls in ["LOW", "MEDIUM", "HIGH"]
        if cls in class_index
    }
    risk_score = probabilities.get(label, max(probabilities.values()))
    return {
        "risk_level": label,
        "risk_score": risk_score,
        "probabilities": probabilities,
        "prediction": f"{label.title()} maintenance risk",
        "recommendation": RECOMMENDATIONS[label],
        "contributing_factors": contributing_factors(bundle, features),
        "model_name": bundle.get("model_name", "RandomForestClassifier"),
        "model_version": bundle.get("model_version", "1.0"),
        "data_note": bundle.get("data_note"),
    }


if __name__ == "__main__":
    demo = {
        "asset_age": 12,
        "expected_life": 20,
        "previous_inspections": 6,
        "previous_maintenance": 1,
        "previous_issues": 4,
        "condition": "Poor",
        "damage_type": "Crack",
        "severity": "High",
        "days_since_inspection": 280,
        "days_since_maintenance": 500,
    }
    print(predict_risk(demo))
