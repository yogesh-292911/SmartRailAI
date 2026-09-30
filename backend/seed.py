"""Insert demo users, assets, QR codes, and a sample history timeline."""

from __future__ import annotations

from datetime import date

from werkzeug.security import generate_password_hash

from models.db import execute, query_one

DEMO_USERS = [
    {
        "employee_id": "ADMIN001",
        "name": "Yogesh Kumar",
        "email": "admin@smartrail.local",
        "password": "Admin@123",
        "role": "ADMIN",
    },
    {
        "employee_id": "INSP001",
        "name": "Anita Rao",
        "email": "inspector@smartrail.local",
        "password": "Inspect@123",
        "role": "INSPECTOR",
    },
    {
        "employee_id": "MAINT001",
        "name": "Ravi Menon",
        "email": "maintenance@smartrail.local",
        "password": "Maint@123",
        "role": "MAINTENANCE",
    },
]

DEMO_ASSETS = [
    {
        "asset_code": "SR-TRK-00145",
        "asset_type": "Rail Fastener / Clip",
        "railway_zone": "Southern Railway",
        "section": "Chennai–Arakkonam",
        "location": "KM 124/6",
        "manufacturer": "RINL",
        "installation_date": "2022-03-12",
        "expected_life": 20,
        "description": "Demonstration fastener used in the college viva flow.",
    },
    {
        "asset_code": "SR-TRK-00021",
        "asset_type": "Fish Plate",
        "railway_zone": "Southern Railway",
        "section": "Jolarpettai–Salem",
        "location": "KM 86/2",
        "manufacturer": "SAIL",
        "installation_date": "2019-08-01",
        "expected_life": 25,
        "description": "Joint fish plate on main line.",
    },
    {
        "asset_code": "SR-TRK-00034",
        "asset_type": "Rail Bolt",
        "railway_zone": "South Western Railway",
        "section": "Bangalore–Mysore",
        "location": "KM 42/1",
        "manufacturer": "Local vendor",
        "installation_date": "2021-01-20",
        "expected_life": 18,
        "description": "Track fastening bolt.",
    },
    {
        "asset_code": "SR-TRK-00048",
        "asset_type": "Sleeper",
        "railway_zone": "Southern Railway",
        "section": "Madurai–Dindigul",
        "location": "KM 12/4",
        "manufacturer": "PSC Sleeper Plant",
        "installation_date": "2018-11-05",
        "expected_life": 30,
        "description": "Concrete sleeper.",
    },
    {
        "asset_code": "SR-TRK-00055",
        "asset_type": "Track Joint",
        "railway_zone": "Southern Railway",
        "section": "Coimbatore–Palakkad",
        "location": "KM 201/3",
        "manufacturer": "IR standard",
        "installation_date": "2020-06-18",
        "expected_life": 22,
        "description": "Insulated track joint.",
    },
    {
        "asset_code": "SR-TRK-00062",
        "asset_type": "Switch/Point Component",
        "railway_zone": "Southern Railway",
        "section": "Basin Bridge Yard",
        "location": "Point 14A",
        "manufacturer": "IR standard",
        "installation_date": "2017-02-09",
        "expected_life": 20,
        "description": "Point switch component.",
    },
]


def seed() -> None:
    for user in DEMO_USERS:
        existing = query_one(
            "SELECT id FROM users WHERE employee_id=%s",
            (user["employee_id"],),
        )
        if existing:
            continue
        execute(
            """
            INSERT INTO users (employee_id, name, email, password_hash, role)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (
                user["employee_id"],
                user["name"],
                user["email"],
                generate_password_hash(user["password"]),
                user["role"],
            ),
        )

    inspector = query_one("SELECT id FROM users WHERE employee_id='INSP001'")
    for asset in DEMO_ASSETS:
        existing = query_one(
            "SELECT id FROM assets WHERE asset_code=%s",
            (asset["asset_code"],),
        )
        if existing:
            asset_id = existing["id"]
        else:
            asset_id = execute(
                """
                INSERT INTO assets (
                    asset_code, asset_type, railway_zone, section, location,
                    manufacturer, installation_date, expected_life, status, description
                ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,'ACTIVE',%s)
                """,
                (
                    asset["asset_code"],
                    asset["asset_type"],
                    asset["railway_zone"],
                    asset["section"],
                    asset["location"],
                    asset["manufacturer"],
                    asset["installation_date"],
                    asset["expected_life"],
                    asset["description"],
                ),
            )
        qr = query_one("SELECT id FROM qr_codes WHERE asset_id=%s", (asset_id,))
        if not qr:
            execute(
                """
                INSERT INTO qr_codes (asset_id, qr_code, generated_date, status)
                VALUES (%s, %s, %s, 'ACTIVE')
                """,
                (asset_id, asset["asset_code"], date.today()),
            )

    # History for the main demo asset SR-TRK-00145
    demo = query_one("SELECT id FROM assets WHERE asset_code='SR-TRK-00145'")
    if demo and inspector:
        prior = query_one(
            "SELECT id FROM inspections WHERE asset_id=%s LIMIT 1",
            (demo["id"],),
        )
        if not prior:
            execute(
                """
                INSERT INTO inspections (
                    asset_id, inspector_id, inspection_date, condition_rating,
                    severity, damage_type, remarks
                ) VALUES (%s,%s,%s,'Good','Low','None','Baseline inspection after installation.')
                """,
                (demo["id"], inspector["id"], date(2024, 4, 10)),
            )
            execute(
                """
                INSERT INTO maintenance (
                    asset_id, priority, action, scheduled_date, completed_date,
                    status, remarks
                ) VALUES (%s,'MEDIUM','Fastener replaced',%s,%s,'COMPLETED','Clip replaced during scheduled block.')
                """,
                (demo["id"], date(2025, 2, 1), date(2025, 2, 3)),
            )

    print("Seed complete.")
    print("Login accounts:")
    print("  ADMIN001 / Admin@123")
    print("  INSP001  / Inspect@123")
    print("  MAINT001 / Maint@123")
    print("Scan demo QR payload: SR-TRK-00145")


if __name__ == "__main__":
    seed()
