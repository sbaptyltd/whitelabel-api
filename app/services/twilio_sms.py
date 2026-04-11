import random
from twilio.rest import Client
from app.core.config import settings


def generate_otp(length: int = 6) -> str:
    return ''.join(str(random.randint(0, 9)) for _ in range(length))


def normalize_phone_number(phone_number: str) -> str:
    phone_number = phone_number.strip().replace(" ", "")

    if phone_number.startswith("+"):
        return phone_number

    if phone_number.startswith("0"):
        return "+61" + phone_number[1:]

    return phone_number


def send_sms_otp(phone_number: str, otp_code: str) -> dict:
    account_sid = settings.TWILIO_ACCOUNT_SID.strip()
    auth_token = settings.TWILIO_AUTH_TOKEN.strip()
    twilio_number = settings.TWILIO_PHONE_NUMBER.strip()

    if not account_sid:
        raise ValueError("TWILIO_ACCOUNT_SID is not configured")

    if not auth_token:
        raise ValueError("TWILIO_AUTH_TOKEN is not configured")

    if not twilio_number:
        raise ValueError("TWILIO_PHONE_NUMBER is not configured")

    client = Client(account_sid, auth_token)
    to_number = normalize_phone_number(phone_number)

    message = client.messages.create(
        body=f"Your OTP is {otp_code}. It will expire in {settings.OTP_EXPIRY_MINUTES} minutes.",
        from_=twilio_number,
        to=to_number,
    )

    return {
        "sid": message.sid,
        "status": message.status,
        "to": to_number,
    }