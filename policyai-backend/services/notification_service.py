import firebase_admin
from firebase_admin import messaging
from typing import List, Dict, Optional


async def send_push_notification(
    fcm_token: str,
    title: str,
    body: str,
    data: Optional[Dict[str, str]] = None
):
    """
    Send FCM push notification to a single device
    
    Args:
        fcm_token: Single FCM token string
        title: Notification title
        body: Notification body
        data: Optional data payload
    """
    try:
        # Convert data dict values to strings (FCM requirement)
        string_data = {}
        if data:
            string_data = {k: str(v) for k, v in data.items()}
        
        # Build FCM message
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=string_data,
            token=fcm_token,
        )
        
        # Send notification
        response = messaging.send(message)
        print(f"✅ Notification sent successfully: {response}")
        return {"success": True, "message_id": response}
        
    except Exception as e:
        print(f"❌ Error sending notification to {fcm_token[:20]}...: {e}")
        raise


async def send_push_notification_bulk(
    fcm_tokens: List[str],
    title: str,
    body: str,
    data: Optional[Dict[str, str]] = None
):
    """
    Send FCM push notifications to multiple devices
    
    Args:
        fcm_tokens: List of FCM token strings
        title: Notification title
        body: Notification body
        data: Optional data payload
    """
    try:
        # Convert data dict values to strings
        string_data = {}
        if data:
            string_data = {k: str(v) for k, v in data.items()}
        
        # Build multicast message
        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=string_data,
            tokens=fcm_tokens,
        )
        
        # Send to multiple devices
        response = messaging.send_multicast(message)
        print(f"✅ Sent {response.success_count}/{len(fcm_tokens)} notifications")
        
        if response.failure_count > 0:
            for idx, resp in enumerate(response.responses):
                if not resp.success:
                    print(f"❌ Failed to send to token {idx}: {resp.exception}")
        
        return {
            "success": True,
            "success_count": response.success_count,
            "failure_count": response.failure_count
        }
        
    except Exception as e:
        print(f"❌ Error sending bulk notifications: {e}")
        raise


# Legacy function for backward compatibility
def send_new_policy_notification(policy_title: str):
    """
    Placeholder for old fcm_service calls
    This is a no-op now - actual notifications sent via send_push_notification
    """
    print(f"📢 Legacy notification call for: {policy_title}")
    pass
