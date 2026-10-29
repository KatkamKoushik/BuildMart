import hashlib
import hmac
import json
import time

from fastapi import APIRouter, Depends, Header, HTTPException, Request, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import require_authenticated_user
from app.db.session import get_db
from app.models.models import Order, User, WebhookEvent
from app.schemas.schemas import (
    RazorpayOrderCreate,
    RazorpayVerifyRequest,
    WebhookResponse,
)

router = APIRouter(prefix="/checkout", tags=["Checkout"])

@router.post("/razorpay/create-order")
async def create_razorpay_order(
    payload: RazorpayOrderCreate,
    current_user: User = Depends(require_authenticated_user),  # noqa: B008
    db: AsyncSession = Depends(get_db)  # noqa: B008
):
    """
    F-01: Creates Razorpay order for online payment.
    Amount is strictly determined server-side in paise.
    """
    result = await db.execute(
        select(Order).where(
            (Order.id == payload.order_id) | (Order.order_number == payload.order_id)
        )
    )
    order = result.scalars().first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if order.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access forbidden: You do not own this order"
        )

    amount_in_paise = round(order.total_amount * 100)
    if amount_in_paise <= 0:
        raise HTTPException(status_code=400, detail="Payment amount must be greater than zero")

    receipt = payload.receipt or f"rcpt_{int(time.time())}"

    # If live Razorpay credentials configured, call Razorpay API
    if (
        settings.RAZORPAY_KEY_ID
        and settings.RAZORPAY_KEY_SECRET
        and not settings.RAZORPAY_KEY_SECRET.startswith("mock_")
    ):
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
        except Exception as e:  # noqa: BLE001
            raise HTTPException(status_code=502, detail=f"Razorpay provider error: {e!s}")

    # Deterministic development / test sandbox order ID
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
    current_user: User = Depends(require_authenticated_user),  # noqa: B008
    db: AsyncSession = Depends(get_db)  # noqa: B008
):
    """
    F-01 & F-11: Authoritative Payment Verification.
    1. Verifies HMAC-SHA256 signature using provider secret.
    2. Identifies matching internal Order.
    3. Prevents duplicate transitions; updates order to 'paid' and 'confirmed'.
    """
    body = f"{payload.razorpay_order_id}|{payload.razorpay_payment_id}"
    expected_signature = hmac.new(
        settings.RAZORPAY_KEY_SECRET.encode("utf-8"),
        body.encode("utf-8"),
        hashlib.sha256
    ).hexdigest()

    # Strict constant-time HMAC check
    if not hmac.compare_digest(expected_signature, payload.razorpay_signature):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid payment signature: Signature mismatch"
        )

    # Locate and update internal Order if referenced
    order = None
    if payload.order_id:
        result = await db.execute(
            select(Order).where(
                (Order.id == payload.order_id) | (Order.order_number == payload.order_id)
            )
        )
        order = result.scalars().first()
    elif payload.razorpay_order_id:
        result = await db.execute(
            select(Order).where(Order.razorpay_order_id == payload.razorpay_order_id)
        )
        order = result.scalars().first()

    if order:
        # Check ownership
        if order.user_id != current_user.id and current_user.role != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access forbidden: You do not own this order"
            )

        # Idempotent handling: if already paid, return success without re-modifying
        if order.payment_status != "paid":
            order.payment_status = "paid"
            order.status = "confirmed"
            order.razorpay_order_id = payload.razorpay_order_id
            order.razorpay_payment_id = payload.razorpay_payment_id
            order.razorpay_signature = payload.razorpay_signature
            await db.commit()
            await db.refresh(order)

    return {
        "verified": True,
        "message": "Payment verified successfully",
        "order_id": payload.razorpay_order_id,
        "payment_id": payload.razorpay_payment_id,
        "internal_order_id": order.id if order else None
    }

@router.post("/razorpay/webhook", response_model=WebhookResponse)
async def razorpay_webhook(
    request: Request,
    x_razorpay_signature: str | None = Header(None),
    db: AsyncSession = Depends(get_db)  # noqa: B008
):
    """
    F-01: Razorpay Webhook Verification with raw request body HMAC-SHA256
    and idempotent replay protection.
    """
    if not x_razorpay_signature:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Missing X-Razorpay-Signature header"
        )

    raw_body = await request.body()
    expected_signature = hmac.new(
        settings.RAZORPAY_WEBHOOK_SECRET.encode("utf-8"),
        raw_body,
        hashlib.sha256
    ).hexdigest()

    if not hmac.compare_digest(expected_signature, x_razorpay_signature):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid webhook signature"
        )

    try:
        event_data = json.loads(raw_body.decode("utf-8"))
    except Exception:  # noqa: BLE001
        raise HTTPException(status_code=400, detail="Invalid JSON webhook payload")

    event_id = event_data.get("id") or event_data.get("event_id") or f"evt_{int(time.time()*1000)}"
    event_type = event_data.get("event", "unknown")

    # Idempotency check: prevent duplicate webhook replay attacks
    existing_evt = await db.execute(select(WebhookEvent).where(WebhookEvent.event_id == event_id))
    if existing_evt.scalars().first():
        return WebhookResponse(
            status="duplicate",
            event_id=event_id,
            message="Webhook event already processed"
        )

    # Process recognized payment events
    payload_entity = event_data.get("payload", {})
    payment_entity = payload_entity.get("payment", {}).get("entity", {})
    rzp_order_id = payment_entity.get("order_id")

    if rzp_order_id:
        result = await db.execute(select(Order).where(Order.razorpay_order_id == rzp_order_id))
        order = result.scalars().first()
        if order:
            if event_type in ["payment.captured", "order.paid"]:
                order.payment_status = "paid"
                order.status = "confirmed"
                order.razorpay_payment_id = payment_entity.get("id")
            elif event_type in ["payment.failed"]:
                order.payment_status = "failed"

    # Record event in WebhookEvent table
    new_event = WebhookEvent(
        event_id=event_id,
        event_type=event_type,
        payload=event_data,
        status="processed"
    )
    db.add(new_event)
    await db.commit()

    return WebhookResponse(
        status="success",
        event_id=event_id,
        message=f"Webhook event '{event_type}' processed successfully"
    )
