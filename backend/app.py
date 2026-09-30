import os

from flask import Flask, send_from_directory
from flask_cors import CORS
from flask_jwt_extended import JWTManager

from config import Config
from routes.assets import assets_bp
from routes.auth import auth_bp
from routes.inspections import inspections_bp
from routes.maintenance import maintenance_bp
from routes.reports import reports_bp
from routes.users import users_bp


def create_app() -> Flask:
    app = Flask(__name__)
    app.config.from_object(Config)
    app.config["JWT_SECRET_KEY"] = Config.JWT_SECRET_KEY
    CORS(app)
    JWTManager(app)
    os.makedirs(Config.UPLOAD_FOLDER, exist_ok=True)

    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(assets_bp, url_prefix="/api/assets")
    app.register_blueprint(inspections_bp, url_prefix="/api")
    app.register_blueprint(maintenance_bp, url_prefix="/api/maintenance")
    app.register_blueprint(reports_bp, url_prefix="/api/reports")
    app.register_blueprint(users_bp, url_prefix="/api/users")

    @app.get("/api/health")
    def health():
        return {"ok": True, "app": "SmartRail"}

    @app.get("/uploads/<path:filename>")
    def uploaded_file(filename: str):
        return send_from_directory(Config.UPLOAD_FOLDER, filename)

    @app.get("/download")
    def download_portal():
        html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>SmartRail AI - Mobile App Download</title>
            <style>
                * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
                body { background: #0f172a; color: #f8fafc; display: flex; align-items: center; justify-content: center; min-height: 100vh; padding: 20px; }
                .card { background: #1e293b; border: 1px solid #334155; border-radius: 16px; padding: 28px; max-width: 440px; width: 100%; box-shadow: 0 10px 25px rgba(0,0,0,0.5); text-align: center; }
                .logo { font-size: 42px; margin-bottom: 12px; }
                h1 { font-size: 24px; font-weight: 700; color: #38bdf8; margin-bottom: 8px; }
                p.sub { font-size: 14px; color: #94a3b8; margin-bottom: 24px; }
                .btn { display: block; width: 100%; background: linear-gradient(135deg, #0284c7, #0369a1); color: #fff; font-size: 16px; font-weight: 600; padding: 14px 20px; border-radius: 10px; text-decoration: none; box-shadow: 0 4px 14px rgba(2,132,199,0.4); margin-bottom: 20px; }
                .btn:active { transform: scale(0.98); }
                .info-box { background: #0f172a; border-radius: 10px; padding: 16px; text-align: left; font-size: 13px; color: #cbd5e1; margin-bottom: 16px; border: 1px solid #334155; }
                .info-box h3 { font-size: 14px; color: #38bdf8; margin-bottom: 8px; }
                .info-box ol { padding-left: 18px; line-height: 1.6; }
                .badge { display: inline-block; background: #065f46; color: #34d399; font-size: 11px; padding: 3px 8px; border-radius: 20px; font-weight: 600; margin-bottom: 16px; }
                .cred-tag { font-family: monospace; background: #334155; padding: 2px 6px; border-radius: 4px; color: #f1f5f9; }
            </style>
        </head>
        <body>
            <div class="card">
                <div class="logo">🚆</div>
                <h1>SmartRail AI</h1>
                <p class="sub">Track Asset Management & AI Inspection App</p>
                <div class="badge">● Backend Server Online</div>

                <div style="margin: 16px 0; background: #ffffff; padding: 12px; border-radius: 12px; display: inline-block;">
                    <img src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=http://10.18.72.137:5000/download" alt="Scan to Download" style="display: block; width: 160px; height: 160px;" />
                </div>
                <p style="font-size: 12px; color: #94a3b8; margin-bottom: 16px;">Scan with phone camera or tap button below</p>

                <a href="/smartrail.apk" class="btn" download>📥 Download Android APK</a>

                <div class="info-box">
                    <h3>📲 How to Install on Android</h3>
                    <ol>
                        <li>Tap the download button above.</li>
                        <li>When downloaded, tap the file to open.</li>
                        <li>If prompted with <em>"Install unknown apps"</em>, enable <strong>Allow from this source</strong>.</li>
                        <li>Tap <strong>Install</strong> to complete setup.</li>
                    </ol>
                </div>

                <div class="info-box">
                    <h3>🔑 Demo Credentials</h3>
                    <div style="margin-top: 6px; line-height: 1.6;">
                        <strong>Username:</strong> <span class="cred-tag">admin</span><br>
                        <strong>Password:</strong> <span class="cred-tag">admin123</span><br>
                        <strong>Backend URL:</strong> <span class="cred-tag">http://10.18.72.137:5000</span>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
        return html, 200, {"Content-Type": "text/html; charset=utf-8"}

    @app.get("/smartrail.apk")
    def download_apk():
        apk_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "mobile_app", "build", "app", "outputs", "flutter-apk"))
        apk_file = "app-release.apk"
        if not os.path.exists(os.path.join(apk_dir, apk_file)):
            return "APK is still building or not found. Please wait a moment and refresh.", 404
        return send_from_directory(apk_dir, apk_file, as_attachment=True, download_name="SmartRailAI.apk")

    return app


app = create_app()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
