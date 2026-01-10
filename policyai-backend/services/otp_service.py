import random
import string
from datetime import datetime, timedelta
from typing import Dict
import resend
from config import settings

# Set Resend API key
resend.api_key = settings.RESEND_API_KEY

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
    print(f"✅ OTP stored for {email}: {otp} (expires in 5 min)")


def verify_otp(email: str, otp: str) -> bool:
    """Verify OTP"""
    if email not in otp_storage:
        print(f"❌ No OTP found for {email}")
        return False
    
    stored = otp_storage[email]
    
    # Check expiry
    if datetime.utcnow() > stored["expires_at"]:
        print(f"⏰ OTP expired for {email}")
        del otp_storage[email]
        return False
    
    # Check OTP match
    if stored["otp"] == otp:
        print(f"✅ OTP verified for {email}")
        del otp_storage[email]  # Delete after successful verification
        return True
    
    print(f"❌ OTP mismatch for {email}")
    return False


async def send_otp_email(email: str, otp: str) -> bool:
    """
    Send OTP via email using Resend
    """
    # Print to console for debugging
    print(f"\n📧 Sending EMAIL OTP to {email}: {otp}\n")
    
    try:
        # Check if Resend API key is configured
        if not settings.RESEND_API_KEY or settings.RESEND_API_KEY == "":
            print("⚠️ RESEND_API_KEY not configured. Using console output only.")
            print(f"📧 EMAIL OTP for {email}: {otp}")
            return True
        
        # Send email via Resend
        params = {
            "from": "PolicyAI <onboarding@resend.dev>",  # Default Resend domain
            "to": [email],
            "subject": "Your PolicyAI Login OTP 🔐",
            "html": f"""
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body style="margin: 0; padding: 0; background-color: #f5f5f5; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
                <div style="max-width: 600px; margin: 40px auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                    
                    <!-- Header -->
                    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center;">
                        <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 600;">PolicyAI</h1>
                        <p style="color: rgba(255, 255, 255, 0.9); margin: 8px 0 0 0; font-size: 14px;">Your Voice in National Policy</p>
                    </div>
                    
                    <!-- Body -->
                    <div style="padding: 40px 30px;">
                        <p style="font-size: 16px; color: #333; margin: 0 0 10px 0;">Hello! 👋</p>
                        
                        <p style="font-size: 14px; color: #666; line-height: 1.6; margin: 0 0 30px 0;">
                            Your One-Time Password (OTP) for logging into PolicyAI is:
                        </p>
                        
                        <!-- OTP Box -->
                        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px; text-align: center; margin: 0 0 30px 0;">
                            <div style="color: white; font-size: 42px; letter-spacing: 12px; font-weight: bold; font-family: 'Courier New', monospace;">
                                {otp}
                            </div>
                        </div>
                        
                        <div style="background-color: #f0f9ff; border-left: 4px solid #3b82f6; padding: 15px; border-radius: 6px; margin: 0 0 30px 0;">
                            <p style="font-size: 13px; color: #1e40af; margin: 0;">
                                ⏰ This OTP is valid for <strong>5 minutes</strong>
                            </p>
                        </div>
                        
                        <div style="background-color: #fef3c7; border-left: 4px solid #f59e0b; padding: 15px; border-radius: 6px;">
                            <p style="font-size: 13px; color: #92400e; margin: 0;">
                                🔒 <strong>Security Notice:</strong> If you didn't request this OTP, please ignore this email. Never share your OTP with anyone.
                            </p>
                        </div>
                    </div>
                    
                    <!-- Footer -->
                    <div style="background-color: #f9fafb; padding: 25px 30px; border-top: 1px solid #e5e7eb; text-align: center;">
                        <p style="color: #6b7280; font-size: 12px; margin: 0 0 5px 0;">
                            © 2025 PolicyAI. All rights reserved.
                        </p>
                        <p style="color: #9ca3af; font-size: 11px; margin: 0;">
                            Making democracy more accessible through technology 🇮🇳
                        </p>
                    </div>
                    
                </div>
            </body>
            </html>
            """
        }
        
        email_response = resend.Emails.send(params)
        
        print(f"✅ Email sent successfully via Resend! Message ID: {email_response['id']}")
        return True
        
    except Exception as e:
        print(f"❌ Error sending email via Resend: {str(e)}")
        print(f"📧 Fallback - Console OTP for {email}: {otp}")
        # Don't fail - still return True so login works
        return True
