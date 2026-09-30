# SmartRail

**SmartRail: AI-Based Laser QR Tracking and Predictive Maintenance App for Railway Track Assets**

Android app (Flutter) + local Flask API + MySQL + Random Forest.

This is a college prototype. The AI model is trained on **synthetic data**, not official Indian Railways data. Predictions are maintenance-risk estimates, not safety certification.

There is **no user-facing website**. Inspectors use the Android app only. The backend runs on your laptop for the demo.

## Can I install everything in the Cursor terminal?

**Yes, mostly.**

| Tool | Cursor terminal? | Notes |
|---|---|---|
| Python | Yes | `winget install Python.Python.3.12` |
| Flutter | Yes | `winget install Google.Flutter` then **restart the terminal** |
| Android Studio | Yes to start the installer | You still finish SDK setup in the Android Studio GUI (`flutter doctor`) |
| MySQL | Yes or XAMPP | XAMPP is often easier on Windows |
| Git | Yes | optional |

Android Studio is a GUI app. The terminal can **launch the installer**; you click through it once.

After any `winget` install, **close the terminal tab and open a new one** so PATH updates.

### Commands to paste in Cursor PowerShell

```powershell
winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
winget install -e --id Google.AndroidStudio --accept-package-agreements --accept-source-agreements
```

Flutter SDK is **not** on winget. Install it with Git (also from the terminal):

```powershell
winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
```

Reopen the terminal, then:

```powershell
cd C:\
git clone https://github.com/flutter/flutter.git -b stable
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")
$env:Path += ";C:\flutter\bin"
flutter doctor
```

MySQL (pick one):

```powershell
winget install -e --id Oracle.MySQL --accept-package-agreements --accept-source-agreements
```

Or install [XAMPP](https://www.apachefriends.org/) and start MySQL from the XAMPP control panel.

Then:

```powershell
flutter doctor
```

Accept Android licenses if asked:

```powershell
flutter doctor --android-licenses
```

## Project layout

```
SmartRailAI/
  mobile_app/     Flutter Android app
  backend/        Flask REST API
  ai/             Synthetic dataset + Random Forest
  database/       schema.sql
  scripts/        Windows install helper
```

## 1. Create the database

In MySQL (Workbench, XAMPP phpMyAdmin, or `mysql` CLI):

```sql
SOURCE C:/SmartRailAI/database/schema.sql;
```

Or:

```powershell
mysql -u root -p < database/schema.sql
```

If your MySQL root password is not empty, set it in `backend/.env`:

```
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DB=smartrail
```

Copy `backend/.env.example` to `backend/.env` and edit.

## 2. Python backend + synthetic AI model

Open a **new** terminal after installing Python:

```powershell
cd C:\SmartRailAI
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r backend\requirements.txt
```

Generate synthetic data, train the model, seed demo users:

```powershell
cd C:\SmartRailAI\ai
python generate_dataset.py
python train_model.py
cd C:\SmartRailAI\backend
python seed.py
python app.py
```

API: `http://127.0.0.1:5000/api/health`

For the phone, bind is already `0.0.0.0:5000`. Find your laptop IP:

```powershell
ipconfig
```

Use the Wi-Fi IPv4, for example `192.168.1.10`. Phone and laptop must be on the **same Wi-Fi**.

### Demo logins

| Role | Employee ID | Password |
|---|---|---|
| Admin | ADMIN001 | Admin@123 |
| Inspector | INSP001 | Inspect@123 |
| Maintenance | MAINT001 | Maint@123 |

Demo QR payload: `SR-TRK-00145`

## 3. Flutter Android app

```powershell
cd C:\SmartRailAI\mobile_app
flutter create . --org com.smartrail --project-name smart_rail --platforms android
```

If `flutter create` asks about existing files, keep the `lib/` code that is already in this repo.

Add camera / internet permission in `mobile_app/android/app/src/main/AndroidManifest.xml` inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

Also allow HTTP to the laptop (Android blocks cleartext by default). In the same manifest `<application>` tag add:

```xml
android:usesCleartextTraffic="true"
```

Run:

```powershell
cd C:\SmartRailAI\mobile_app
flutter pub get
flutter run
```

Or build an APK:

```powershell
flutter build apk --debug
```

APK path: `mobile_app/build/app/outputs/flutter-apk/app-debug.apk`

On the login screen, set **Backend URL** to `http://YOUR_LAPTOP_IP:5000`.

## Faculty demo flow

1. Admin logs in → Assets → add or open `SR-TRK-00145` → Show QR → print/screenshot.
2. Inspector logs in → Scan QR (or type `SR-TRK-00145`) → New Inspection → Poor / Crack / High → photo → Submit.
3. AI screen shows LOW / MEDIUM / HIGH with a risk %. High risk creates a maintenance job.
4. Maintenance officer → Jobs → Assign → In Progress → Complete.
5. View History. Admin → Reports (live counts from MySQL).

## AI note (use this in the report)

Training used **5,000 synthetically generated records** (`ai/dataset.csv`) with an 80/20 train-test split and a Random Forest classifier (`ai/model.pkl`). Metrics are written to `ai/metrics.json` after training. This is **not** Indian Railways operational data.
