import os
from dotenv import load_dotenv


load_dotenv()

class Settings:
    APP_NAME = os.getenv("APP_NAME", "WhiteLabel Commerce API")
    APP_ENV = os.getenv("APP_ENV", "dev")
    DB_USER = os.getenv("DB_USER", "app_user")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "changeme")
    DB_NAME = os.getenv("DB_NAME", "white_label_commerce")
    DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
    DB_PORT = int(os.getenv("DB_PORT", "3306"))
    JWT_SECRET = os.getenv("JWT_SECRET", "change-me")
    ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "43200"))
    OTP_EXPIRY_MINUTES = int(os.getenv("OTP_EXPIRY_MINUTES", "5"))

    TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID", "")
    TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN", "")
    TWILIO_PHONE_NUMBER = os.getenv("TWILIO_PHONE_NUMBER", "")

settings = Settings()