import os

from dotenv import load_dotenv

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(BASE_DIR)
load_dotenv(os.path.join(BASE_DIR, ".env"))


class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "smartrail-college-demo-secret")
    JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY", "smartrail-jwt-secret")
    MYSQL_HOST = os.environ.get("MYSQL_HOST", "127.0.0.1")
    MYSQL_PORT = int(os.environ.get("MYSQL_PORT", "3306"))
    MYSQL_USER = os.environ.get("MYSQL_USER", "root")
    MYSQL_PASSWORD = os.environ.get("MYSQL_PASSWORD", "")
    MYSQL_DB = os.environ.get("MYSQL_DB", "smartrail")
    UPLOAD_FOLDER = os.path.join(BASE_DIR, "uploads")
    MODEL_PATH = os.path.join(ROOT_DIR, "ai", "model.pkl")
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024
