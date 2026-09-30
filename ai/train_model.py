"""Train a Random Forest maintenance-risk classifier on synthetic data."""

from __future__ import annotations

import json
from pathlib import Path

import joblib
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split

from generate_dataset import OUT_PATH as DATASET_PATH

AI_DIR = Path(__file__).resolve().parent
MODEL_PATH = AI_DIR / "model.pkl"
METRICS_PATH = AI_DIR / "metrics.json"

FEATURES = [
    "asset_age",
    "expected_life",
    "previous_inspections",
    "previous_maintenance",
    "previous_issues",
    "condition_enc",
    "damage_enc",
    "severity_enc",
    "days_since_inspection",
    "days_since_maintenance",
]


def main() -> None:
    if not DATASET_PATH.exists():
        raise SystemExit("dataset.csv missing. Run generate_dataset.py first.")

    df = pd.read_csv(DATASET_PATH)
    x = df[FEATURES]
    y = df["risk_level"]

    x_train, x_test, y_train, y_test = train_test_split(
        x, y, test_size=0.2, random_state=42, stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=180,
        max_depth=12,
        min_samples_split=4,
        random_state=42,
        n_jobs=-1,
        class_weight="balanced",
    )
    model.fit(x_train, y_train)
    y_pred = model.predict(x_test)
    report = classification_report(y_test, y_pred, output_dict=True)
    matrix = confusion_matrix(y_test, y_pred, labels=["LOW", "MEDIUM", "HIGH"])

    bundle = {
        "model": model,
        "features": FEATURES,
        "classes": list(model.classes_),
        "feature_importances": {
            name: float(value)
            for name, value in zip(FEATURES, model.feature_importances_)
        },
        "data_note": "Trained on synthetic SmartRail data, not official railway data.",
        "model_name": "RandomForestClassifier",
        "model_version": "1.0",
    }
    joblib.dump(bundle, MODEL_PATH)

    metrics = {
        "accuracy": report["accuracy"],
        "precision_macro": report["macro avg"]["precision"],
        "recall_macro": report["macro avg"]["recall"],
        "f1_macro": report["macro avg"]["f1-score"],
        "per_class": {
            label: report[label]
            for label in ["LOW", "MEDIUM", "HIGH"]
            if label in report
        },
        "confusion_matrix_labels": ["LOW", "MEDIUM", "HIGH"],
        "confusion_matrix": matrix.tolist(),
        "n_train": int(len(x_train)),
        "n_test": int(len(x_test)),
        "data_note": bundle["data_note"],
    }
    METRICS_PATH.write_text(json.dumps(metrics, indent=2), encoding="utf-8")

    print(classification_report(y_test, y_pred, digits=3))
    print("Confusion matrix [LOW, MEDIUM, HIGH]:")
    print(matrix)
    print(f"Saved model -> {MODEL_PATH}")
    print(f"Saved metrics -> {METRICS_PATH}")


if __name__ == "__main__":
    main()
