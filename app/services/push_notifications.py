import os
import firebase_admin
from firebase_admin import credentials, messaging
from sqlalchemy import text


def _init_firebase():
    if firebase_admin._apps:
        return

    key_path = os.getenv("FIREBASE_SERVICE_ACCOUNT_FILE", "app/firebase/firebase-key.json")

    if os.path.exists(key_path):
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
        print(f"[FCM] Firebase initialized with service account file: {key_path}")
    else:
        firebase_admin.initialize_app()
        print("[FCM] Firebase initialized with default credentials")


_init_firebase()


def send_push_notification(db, user_id: int, title: str, body: str):
    rows = db.execute(
        text(
            """
            SELECT DISTINCT fcm_token
            FROM user_sessions
            WHERE user_id = :user_id
              AND fcm_token IS NOT NULL
              AND fcm_token <> ''
              AND expires_at > NOW()
            """
        ),
        {"user_id": user_id},
    ).mappings().all()

    if not rows:
        print(f"[FCM] No active FCM token found for user_id={user_id}")
        return {
            "sent": 0,
            "failed": 0,
            "message": "No active FCM token found",
        }

    sent = 0
    failed = 0

    for row in rows:
        token = row["fcm_token"]

        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data={
                    "type": "ORDER_NOTIFICATION",
                    "user_id": str(user_id),
                },
                token=token,
            )

            response = messaging.send(message)
            sent += 1
            print(f"[FCM] Push sent user_id={user_id} response={response}")

        except Exception as e:
            failed += 1
            print(f"[FCM] Push failed user_id={user_id} error={e}")

    return {
        "sent": sent,
        "failed": failed,
    }