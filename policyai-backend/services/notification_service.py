import requests
from typing import List

def send_push_notification(fcm_tokens: List[str], title: str, body: str, data: dict = None):
    """Send push notification via Firebase Admin SDK"""
    
    # You'll need Firebase Admin SDK credentials
    # For now, this is a placeholder
    
    url = "https://fcm.googleapis.com/fcm/send"
    headers = {
        "Authorization": "key=YOUR_SERVER_KEY",  # Get from Firebase Console
        "Content-Type": "application/json"
    }
    
    for token in fcm_tokens:
        payload = {
            "to": token,
            "notification": {
                "title": title,
                "body": body
            },
            "data": data or {}
        }
        
        response = requests.post(url, json=payload, headers=headers)
        print(f"Notification sent: {response.status_code}")
