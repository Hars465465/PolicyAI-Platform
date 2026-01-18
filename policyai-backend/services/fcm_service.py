import firebase_admin
from firebase_admin import credentials, messaging
from typing import List
import os

# Initialize Firebase Admin SDK (do this once)
if not firebase_admin._apps:
    cred = credentials.Certificate(os.getenv('FIREBASE_CREDENTIALS_PATH', 'firebase-credentials.json'))
    firebase_admin.initialize_app(cred)


def send_notification_to_token(token: str, title: str, body: str, data: dict = None):
    """Send notification to a single device"""
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=token,
        )
        
        response = messaging.send(message)
        print(f"✅ Notification sent successfully: {response}")
        return True
        
    except Exception as e:
        print(f"❌ Error sending notification: {e}")
        return False


def send_notification_to_multiple(tokens: List[str], title: str, body: str, data: dict = None):
    """Send notification to multiple devices"""
    try:
        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            tokens=tokens,  # List of FCM tokens
        )
        
        response = messaging.send_multicast(message)
        print(f"✅ {response.success_count} notifications sent")
        print(f"❌ {response.failure_count} notifications failed")
        return response
        
    except Exception as e:
        print(f"❌ Error sending notifications: {e}")
        return None


def send_new_policy_notification(policy_title: str):
    """Notify all users about new policy"""
    from database import get_db
    from models.user import User
    
    db = next(get_db())
    
    # Get all users with FCM tokens
    users = db.query(User).filter(User.fcm_token.isnot(None)).all()
    tokens = [user.fcm_token for user in users]
    
    if not tokens:
        print("No users with FCM tokens")
        return
    
    send_notification_to_multiple(
        tokens=tokens,
        title="🗳️ New Policy Added!",
        body=f"Vote now on: {policy_title}",
        data={"type": "new_policy", "title": policy_title}
    )
