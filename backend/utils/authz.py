from flask_jwt_extended import get_jwt, get_jwt_identity, verify_jwt_in_request
from functools import wraps
from flask import jsonify

from models.db import query_one


def current_user() -> dict | None:
    verify_jwt_in_request()
    return query_one("SELECT * FROM users WHERE id=%s", (get_jwt_identity(),))


def role_required(*roles):
    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            verify_jwt_in_request()
            claims = get_jwt()
            if claims.get("role") not in roles:
                return jsonify({"error": "Not allowed for this role"}), 403
            return fn(*args, **kwargs)

        return wrapper

    return decorator
