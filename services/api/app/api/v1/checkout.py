import hmac
import hashlib
import time
import json
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Request, Header, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.core.config import settings
from app.schemas.schemas import RazorpayOrderCreate, RazorpayVerifyRequest, WebhookResponse
from app.core.security import require_authenticated_user
from app.models.models import User, Order, WebhookEvent

router = APIRouter(prefix="/checkout", tags=["Checkout"])

@router.post("/razorpay/create-order")
async def create_razorpay_order(
    payload: RazorpayOrderCreate,
    current_user: User = Depends(require_authenticated_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Authoritative payment initiation.
    - Strictly requires a verified, persisted Order record.
    - Rejects unverified amounts; derives amount authoritatively from order.total_amount.
    - Enforces ownership: only order owner or admin can initiate payment.
    - Rejects already paid or cancelled orders.
    - Fails closed in production if live Razorpay credentials are missing.
    """
    target_order_id = payload.order_id or payload.receipt
    if not target_order_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A valid persisted order ID is required to initiate checkout payment"
        )

    result = await db.execute(
        select(Order).where(
            (Order.id == target_order_id) | (Order.order_number == target_order_id)
        )
    )
    order = result.scalars().first()

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order '{target_order_id}' not found. Cannot initiate payment without a verified order."
        )

    if order.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access forbidden: You do not have permission to pay for this order"
        )

    if order.payment_status == "paid":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Order has already been paid"
        )

    if order.status in ["cancelled", "delivered"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot initiate payment for order in '{order.status}' status"
        )

    # Server-authoritative payable amount derived strictly from persisted order
    amount_in_paise = int(round(order.total_amount * 100))
    if amount_in_paise <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payable order amount must be greater than zero"
        )

    receipt = order.order_number

    # Live/Sandbox Razorpay credentials configured
    if (
        settings.RAZORPAY_KEY_ID
        and settings.RAZORPAY_KEY_SECRET
        and not settings.RAZORPAY_KEY_SECRET.startswith("mock_")
        and "mock" not in settings.RAZORPAY_KEY_SECRET.lower()
        and not settings.RAZORPAY_KEY_SECRET.startswith("your_")
        and not settings.RAZORPAY_KEY_ID.startswith("mock_")
    ):
        try:
            import razorpay
            client = razorpay.Client(auth=(settings.RAZORPAY_KEY_ID, settings.RAZORPAY_KEY_SECRET))
            order_data = {
                "amount": amount_in_paise,
                "currency": payload.currency or "INR",
                "receipt": receipt,
                "payment_capture": 1
            }
            rzp_order = client.order.create(data=order_data)
            order.razorpay_order_id = rzp_order["id"]
            await db.commit()
            await db.refresh(order)
            return {
                "order_id": rzp_order["id"],
                "amount": rzp_order["amount"],
                "currency": rzp_order["currency"],
                "key_id": settings.RAZORPAY_KEY_ID
            }
        except Exception as e:
            raise HTTPException(status_code=502, detail=f"Razorpay provider error: {str(e)}")

    # Fail closed in production mode when live credentials are absent
    if settings.ENVIRONMENT.lower() == "production":
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Production payment gateway is unconfigured or unavailable. Valid RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET required."
        )

    # Deterministic development sandbox order ID
    mock_order_id = f"order_{int(time.time())}_{current_user.id[:8]}"
    order.razorpay_order_id = mock_order_id
    await db.commit()
    await db.refresh(order)

    return {
        "order_id": mock_order_id,
        "amount": amount_in_paise,
        "currency": payload.currency or "INR",
        "key_id": settings.RAZORPAY_KEY_ID
    }


@router.post("/razorpay/verify")
async def verify_razorpay_payment(
    payload: RazorpayVerifyRequest,
    current_user: User = Depends(require_authenticated_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Authoritative payment verification.
    - Constant-time HMAC-SHA256 signature verification.
    - Matches and validates internal Order ownership and status.
    - Idempotent state transitions preventing double-confirmation.
    """
    body = f"{payload.razorpay_order_id}|{payload.razorpay_payment_id}"
    expected_signature = hmac.new(
        settings.RAZORPAY_KEY_SECRET.encode("utf-8"),
        body.encode("utf-8"),
        hashlib.sha256
    ).hexdigest()

    if not hmac.compare_digest(expected_signature, payload.razorpay_signature):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid payment signature: Signature mismatch"
        )

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
        if order.user_id != current_user.id and current_user.role != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access forbidden: You do not own this order"
            )

        if order.razorpay_order_id and order.razorpay_order_id != payload.razorpay_order_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Payment order ID mismatch with registered order"
            )

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
    x_razorpay_signature: Optional[str] = Header(None),
    db: AsyncSession = Depends(get_db)
):
    """
    Razorpay Webhook Verification.
    - Constant-time HMAC-SHA256 signature verification over exact raw bytes.
    - Replay attack deduplication.
    - Transactional state updates.
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
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid JSON webhook payload")

    event_id = event_data.get("id") or event_data.get("event_id") or f"evt_{int(time.time()*1000)}"
    event_type = event_data.get("event", "unknown")

    # Prevent duplicate webhook replays
    existing_evt = await db.execute(select(WebhookEvent).where(WebhookEvent.event_id == event_id))
    if existing_evt.scalars().first():
        return WebhookResponse(
            status="duplicate",
            event_id=event_id,
            message="Webhook event already processed"
        )

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
