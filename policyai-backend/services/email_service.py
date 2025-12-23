import random
import string
from datetime import datetime, timedelta
from typing import Dict

# In-memory OTP storage (use Redis in production)
otp_storage: Dict[str, Dict] = {}

def generate_otp() -> str:
    """Generate 6-digit OTP"""
    return ''.join(random.choices(string.digits, k=6))

def store_otp(email: str, otp: str) -> None:
    """Store OTP with 5-minute expiry"""
    otp_storage[email] = {
        "otp": otp,
        "expires_at": datetime.utcnow() + timedelta(minutes=5)
    }

def verify_otp(email: str, otp: str) -> bool:
    """Verify OTP"""
    if email not in otp_storage:
        return False
    
    stored = otp_storage[email]
    
    # Check expiry
    if datetime.utcnow() > stored["expires_at"]:
        del otp_storage[email]
        return False
    
    # Check OTP match
    if stored["otp"] == otp:
        del otp_storage[email]  # Delete after successful verification
        return True
    
    return False

async def send_otp_email(email: str, otp: str) -> bool:
    """
    Send OTP via email
    For Phase 1: Just print to console
    For Phase 2: Use Resend or Gmail SMTP
    """
    print(f"\n📧 EMAIL OTP for {email}: {otp}\n")
    
    # TODO Phase 2: Uncomment this
    # from config import settings
    # import resend
    # resend.api_key = settings.RESEND_API_KEY
    # resend.Emails.send({
    #     "from": settings.EMAIL_FROM,
    #     "to": email,
    #     "subject": "Your PolicyAI Login OTP",
    #     "html": f"<h2>Your OTP is: {otp}</h2><p>Valid for 5 minutes.</p>"
    # })
    
    return True
