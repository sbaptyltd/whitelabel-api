
import hashlib
from datetime import datetime, timedelta, timezone
import jwt
from app.core.config import settings

def create_access_token(subject: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {"sub": subject, "exp": expire}
    return jwt.encode(payload, settings.JWT_SECRET, algorithm="HS256")

def decode_access_token(token: str) -> dict:
    return jwt.decode(token, settings.JWT_SECRET, algorithms=["HS256"])

def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()
