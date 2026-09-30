"""Generate a synthetic SmartRail maintenance-risk dataset.

This data is simulated for a college prototype. It is NOT official
Indian Railways inspection data.
"""

from __future__ import annotations

import random
from pathlib import Path

import numpy as np
import pandas as pd

N_ROWS = 5000
SEED = 42
OUT_PATH = Path(__file__).resolve().parent / "dataset.csv"

CONDITIONS = ["Good", "Moderate", "Poor"]
DAMAGE_TYPES = [
    "None",
    "Crack",
    "Wear",
    "Corrosion",
    "Deformation",
    "Loose Component",
    "Other",
]
SEVERITIES = ["Low", "Medium", "High"]
ASSET_TYPES = [
    "Rail Fastener / Clip",
    "Fish Plate",
    "Rail Bolt",
    "Sleeper",
    "Track Joint",
    "Switch/Point Component",
]


def encode_condition(value: str) -> int:
    return CONDITIONS.index(value)


def encode_damage(value: str) -> int:
    return DAMAGE_TYPES.index(value)


def encode_severity(value: str) -> int:
    return SEVERITIES.index(value)


def label_from_score(score: float) -> str:
    if score >= 0.62:
        return "HIGH"
    if score >= 0.35:
        return "MEDIUM"
    return "LOW"


def row_risk_score(rng: random.Random) -> dict:
    asset_age = rng.randint(1, 30)
    expected_life = rng.choice([15, 18, 20, 22, 25, 30])
    previous_inspections = rng.randint(0, 18)
    previous_maintenance = rng.randint(0, 8)
    previous_issues = rng.randint(0, max(0, previous_inspections))
    condition = rng.choices(CONDITIONS, weights=[0.42, 0.33, 0.25])[0]
    damage = rng.choices(
        DAMAGE_TYPES,
        weights=[0.28, 0.18, 0.16, 0.14, 0.10, 0.09, 0.05],
    )[0]
    if damage == "None":
        severity = "Low"
        condition = rng.choices(CONDITIONS, weights=[0.7, 0.25, 0.05])[0]
    else:
        severity = rng.choices(SEVERITIES, weights=[0.25, 0.40, 0.35])[0]
    days_since_inspection = rng.randint(0, 540)
    days_since_maintenance = rng.randint(0, 900)

    age_ratio = asset_age / expected_life
    score = 0.0
    score += encode_condition(condition) * 0.16
    score += 0.0 if damage == "None" else 0.12
    if damage in {"Crack", "Deformation", "Loose Component"}:
        score += 0.10
    score += encode_severity(severity) * 0.14
    score += min(age_ratio, 1.4) * 0.18
    score += min(previous_issues / 8.0, 1.0) * 0.14
    score += min(days_since_inspection / 365.0, 1.5) * 0.10
    score += min(days_since_maintenance / 730.0, 1.4) * 0.08
    score -= min(previous_maintenance / 8.0, 1.0) * 0.05
    score += rng.uniform(-0.08, 0.08)
    score = float(np.clip(score, 0.0, 1.0))

    risk = label_from_score(score)
    # Small label noise so the classifier is not a perfect rule copy.
    if rng.random() < 0.08:
        risk = rng.choice(["LOW", "MEDIUM", "HIGH"])

    return {
        "asset_type": rng.choice(ASSET_TYPES),
        "asset_age": asset_age,
        "expected_life": expected_life,
        "previous_inspections": previous_inspections,
        "previous_maintenance": previous_maintenance,
        "previous_issues": previous_issues,
        "condition": condition,
        "damage_type": damage,
        "severity": severity,
        "days_since_inspection": days_since_inspection,
        "days_since_maintenance": days_since_maintenance,
        "condition_enc": encode_condition(condition),
        "damage_enc": encode_damage(damage),
        "severity_enc": encode_severity(severity),
        "risk_level": risk,
    }


def main() -> None:
    rng = random.Random(SEED)
    rows = [row_risk_score(rng) for _ in range(N_ROWS)]
    df = pd.DataFrame(rows)
    df.to_csv(OUT_PATH, index=False)
    print(f"Wrote {len(df)} synthetic rows to {OUT_PATH}")
    print(df["risk_level"].value_counts().to_string())
    print("NOTE: This dataset is synthetic. It is not Indian Railways data.")


if __name__ == "__main__":
    main()
