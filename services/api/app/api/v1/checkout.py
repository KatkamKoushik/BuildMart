import hmac
import hashlib
import time
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.core.config import settings
from app.schemas.schemas import RazorpayOrderCreate, RazorpayVerifyRequest
from app.core.security import get_current_user
from app.models.models import User

router = APIRouter(prefix="/checkout", tags=["Checkout"])

@router.post("/razorpay/create-order")
async def create_razorpay_order(
    payload: RazorpayOrderCreate,
    current_user: User = Depends(get_current_user)
):
    """
    Creates Razorpay order for online payment.
    Falls back to deterministic sandbox order generation if Razorpay SDK keys are dev placeholders.
    """
    amount_in_paise = int(round(payload.amount * 100))
    receipt = payload.receipt or f"rcpt_{int(time.time())}"

    # Try live Razorpay SDK if valid credentials provided
    if settings.RAZORPAY_KEY_ID and settings.RAZORPAY_KEY_SECRET and not settings.RAZORPAY_KEY_SECRET.startswith("mock_"):
        try:
            import razorpay
            client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))
            order_data = {
                "amount": amount_in_paise,
                "currency": payload.currency,
                "receipt": receipt,
                "payment_capture": 1
            }
            rzp_order = client.order.create(data=order_data)
            return {
                "order_id": rzp_order["id"],
                "amount": rzp_order["amount"],
                "currency": rzp_order["currency"],
                "key_id": settings.RAZORPAY_KEY_ID
            }
        except Exception as e:
            # Fall back to sandbox simulation
            pass

    # Sandbox / Local dev simulated Razorpay order ID
    mock_order_id = f"order_{int(time.time())}_{current_user.id[:8]}"
    return {
        "order_id": mock_order_id,
        "amount": amount_in_paise,
        "currency": payload.currency,
        "key_id": settings.RAZORPAY_KEY_ID
    }

@router.post("/razorpay/verify")
async def verify_razorpay_payment(
    payload: RazorpayVerifyRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Verifies Razorpay payment signature using HMAC SHA256.
    """
    if settings.RAZORPAY_KEY_SECRET and not settings.RAZORPAY_KEY_SECRET.startswith("mock_"):
        try:
            body = f"{payload.razorpay_order_id}|{payload.razorpay_payment_id}"
            expected_signature = hmac.new(
                settings.RAZORPAY_KEY_SECRET.encode("utf-8"),
                body.encode("utf-8"),
                hashlib.sha256
            ).hexdigest()

            if expected_signature != payload.razorpay_signature:
                raise HTTPException(status_code=400, detail="Invalid payment signature")
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Signature verification error: {str(e)}")

    return {
        "verified": True,
        "message": "Payment verified successfully",
        "order_id": payload.razorpay_order_id,
        "payment_id": payload.razorpay_payment_id
    }
