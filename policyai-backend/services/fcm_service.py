import os
from typing import List

# Try to import Firebase, but don't crash if it's not available
try:
    import firebase_admin
    from firebase_admin import credentials, messaging
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False
    print("⚠️ Firebase Admin SDK not installed")

# Initialize Firebase Admin SDK (only if available)
if FIREBASE_AVAILABLE and not firebase_admin._apps:
    try:
        # Try environment variable first (Railway)
        firebase_json = os.getenv('FIREBASE_CREDENTIALS_JSON')
        
        if firebase_json:
            import json
            cred_dict = json.loads(firebase_json)
            cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred)
            print("✅ Firebase initialized from environment variable")
        elif os.path.exists('firebase-credentials.json'):
            # Local development - use file
            cred = credentials.Certificate('firebase-credentials.json')
            firebase_admin.initialize_app(cred)
            print("✅ Firebase initialized from local file")
        else:
            FIREBASE_AVAILABLE = False
            print("⚠️ Firebase credentials not found - FCM disabled")
    except Exception as e:
        FIREBASE_AVAILABLE = False
        print(f"⚠️ Firebase initialization failed: {e}")


def send_notification_to_token(token: str, title: str, body: str, data: dict = None):
    """Send notification to a single device"""
    if not FIREBASE_AVAILABLE:
        print("⚠️ FCM not available, skipping notification")
        return False
    
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
    if not FIREBASE_AVAILABLE:
        print("⚠️ FCM not available, skipping notifications")
        return None
    
    try:
        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            tokens=tokens,
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
    if not FIREBASE_AVAILABLE:
        print("⚠️ FCM not configured, skipping notification")
        return
    
    try:
        from database import get_db
        from models.user import User
        
        db = next(get_db())
        
        # Get all users with FCM tokens
        users = db.query(User).filter(User.fcm_token.isnot(None)).all()
        tokens = [user.fcm_token for user in users]
        
        if not tokens:
            print("⚠️ No users with FCM tokens")
            return
        
        send_notification_to_multiple(
            tokens=tokens,
            title="🗳️ New Policy Added!",
            body=f"Vote now on: {policy_title}",
            data={"type": "new_policy", "title": policy_title}
        )
    except Exception as e:
        print(f"⚠️ Failed to send policy notification: {e}")



