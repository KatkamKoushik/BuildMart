import hmac
import hashlib
import json
import pytest
from app.core.config import Settings, settings

@pytest.mark.asyncio
async def test_unauthenticated_protected_routes(async_client):
    """
    F-02 & F-14: Unauthenticated access to protected routes must be rejected with 401.
    """
    # 1. Orders
    res = await async_client.get("/api/v1/orders")
    assert res.status_code == 401
    assert "token required" in res.json().get("detail", "").lower()

    # 2. Checkout
    res = await async_client.post("/api/v1/checkout/razorpay/create-order", json={"amount": 1000.0})
    assert res.status_code == 401

@pytest.mark.asyncio
async def test_rbac_buyer_denied_admin_routes(async_client):
    """
    F-02: Buyers must not have access to administrator endpoints (403 Forbidden).
    """
    # Login as buyer
    token_res = await async_client.post(
        "/api/v1/auth/token",
        json={"email": "buyer@buildmart.dev", "role": "buyer"}
    )
    assert token_res.status_code == 200
    buyer_token = token_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {buyer_token}"}

    # 1. Metrics
    res = await async_client.get("/api/v1/admin/metrics", headers=headers)
    assert res.status_code == 403
    assert "access forbidden" in res.json()["detail"].lower()

    # 2. Product creation
    prod_payload = {
        "title": "Unauthorized Rogue Product",
        "price": 100.0,
        "category_id": "cement"
    }
    res = await async_client.post("/api/v1/admin/products", json=prod_payload, headers=headers)
    assert res.status_code == 403

@pytest.mark.asyncio
async def test_rbac_admin_allowed_admin_routes(async_client):
    """
    F-02: Authorized administrators can access admin metrics and CRUD products.
    """
    # Login as admin
    token_res = await async_client.post(
        "/api/v1/auth/token",
        json={"email": "admin@buildmart.dev", "role": "admin"}
    )
    assert token_res.status_code == 200
    admin_token = token_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {admin_token}"}

    # 1. Metrics
    res = await async_client.get("/api/v1/admin/metrics", headers=headers)
    assert res.status_code == 200
    metrics = res.json()
    assert metrics["total_products"] > 0
    assert metrics["admin_caller"] == "admin@buildmart.dev"

    # 2. Create product
    prod_payload = {
        "title": "Admin Created Premium Waterproofing",
        "description": "Industrial grade sealant",
        "price": 4500.0,
        "category_id": "cement",
        "stock_quantity": 50,
        "unit": "bucket"
    }
    create_res = await async_client.post("/api/v1/admin/products", json=prod_payload, headers=headers)
    assert create_res.status_code == 201
    created_prod = create_res.json()
    prod_id = created_prod["id"]

    # 3. Delete product
    del_res = await async_client.delete(f"/api/v1/admin/products/{prod_id}", headers=headers)
    assert del_res.status_code == 200
    assert del_res.json()["deleted"] is True

@pytest.mark.asyncio
async def test_resource_ownership_cross_customer_isolation(async_client):
    """
    F-02 & F-10: Customer A cannot view or cancel Customer B's order.
    """
    # Create Customer A and place order
    tok_a = (await async_client.post(
        "/api/v1/auth/token", json={"email": "customera@buildmart.dev", "role": "buyer"}
    )).json()["access_token"]

    prod_res = await async_client.get("/api/v1/products?limit=1")
    test_prod = prod_res.json()[0]

    order_payload = {
        "delivery_address": {"city": "Hyderabad", "phone": "9999999999"},
        "payment_method": "cod",
        "items": [{"productId": test_prod["id"], "quantity": 1}]
    }
    order_a = (await async_client.post(
        "/api/v1/orders",
        json=order_payload,
        headers={"Authorization": f"Bearer {tok_a}"}
    )).json()
    order_id = order_a["id"]

    # Create Customer B
    tok_b = (await async_client.post(
        "/api/v1/auth/token", json={"email": "customerb@buildmart.dev", "role": "buyer"}
    )).json()["access_token"]

    # Customer B attempts to view Customer A's order
    view_res = await async_client.get(
        f"/api/v1/orders/{order_id}",
        headers={"Authorization": f"Bearer {tok_b}"}
    )
    assert view_res.status_code == 403
    assert "access forbidden" in view_res.json()["detail"].lower()

    # Customer B attempts to cancel Customer A's order
    cancel_res = await async_client.post(
        f"/api/v1/orders/{order_id}/cancel",
        headers={"Authorization": f"Bearer {tok_b}"}
    )
    assert cancel_res.status_code == 403

@pytest.mark.asyncio
async def test_server_authoritative_calculations_and_tampering(async_client):
    """
    F-13: Server-authoritative checkout calculations and negative quantity prevention.
    """
    tok = (await async_client.post(
        "/api/v1/auth/token", json={"email": "buyer1@buildmart.dev", "role": "buyer"}
    )).json()["access_token"]
    headers = {"Authorization": f"Bearer {tok}"}

    prod_res = await async_client.get("/api/v1/products?limit=1")
    prod = prod_res.json()[0]

    # Attempt negative quantity
    bad_payload = {
        "delivery_address": {"city": "Hyderabad"},
        "payment_method": "razorpay",
        "items": [{"productId": prod["id"], "quantity": -5}]
    }
    bad_res = await async_client.post("/api/v1/orders", json=bad_payload, headers=headers)
    assert bad_res.status_code == 422

    # Place valid order with razorpay
    valid_payload = {
        "delivery_address": {"city": "Hyderabad"},
        "payment_method": "razorpay",
        "items": [{"productId": prod["id"], "quantity": 2}]
    }
    res = await async_client.post("/api/v1/orders", json=valid_payload, headers=headers)
    assert res.status_code == 201
    order = res.json()

    expected_subtotal = round(prod["price"] * 2, 2)
    expected_tax = round(expected_subtotal * 0.18, 2)
    expected_delivery = 0.0 if expected_subtotal >= 5000 else 250.0
    expected_total = round(expected_subtotal + expected_tax + expected_delivery, 2)

    assert order["subtotal"] == expected_subtotal
    assert order["tax"] == expected_tax
    assert order["delivery_fee"] == expected_delivery
    assert order["total_amount"] == expected_total
    # Must NOT be marked paid prematurely
    assert order["payment_status"] == "pending"
    assert order["status"] == "pending"

@pytest.mark.asyncio
async def test_razorpay_signature_verification_and_tampering(async_client):
    """
    F-01: Razorpay HMAC-SHA256 signature verification and tamper detection.
    """
    tok = (await async_client.post(
        "/api/v1/auth/token", json={"email": "buyer_rzp@buildmart.dev", "role": "buyer"}
    )).json()["access_token"]
    headers = {"Authorization": f"Bearer {tok}"}

    prod = (await async_client.get("/api/v1/products?limit=1")).json()[0]
    order = (await async_client.post(
        "/api/v1/orders",
        json={
            "delivery_address": {"city": "Hyderabad"},
            "payment_method": "razorpay",
            "items": [{"productId": prod["id"], "quantity": 1}]
        },
        headers=headers
    )).json()

    rzp_order_id = "order_test_987654"
    rzp_payment_id = "pay_test_123456"

    # 1. Tampered signature rejected
    bad_verify_res = await async_client.post(
        "/api/v1/checkout/razorpay/verify",
        json={
            "razorpay_order_id": rzp_order_id,
            "razorpay_payment_id": rzp_payment_id,
            "razorpay_signature": "invalid_tampered_signature_hex",
            "order_id": order["id"]
        },
        headers=headers
    )
    assert bad_verify_res.status_code == 400
    assert "invalid payment signature" in bad_verify_res.json()["detail"].lower()

    # 2. Valid signature succeeds and updates order to paid
    body = f"{rzp_order_id}|{rzp_payment_id}"
    valid_sig = hmac.new(
        settings.RAZORPAY_KEY_SECRET.encode("utf-8"),
        body.encode("utf-8"),
        hashlib.sha256
    ).hexdigest()

    good_verify_res = await async_client.post(
        "/api/v1/checkout/razorpay/verify",
        json={
            "razorpay_order_id": rzp_order_id,
            "razorpay_payment_id": rzp_payment_id,
            "razorpay_signature": valid_sig,
            "order_id": order["id"]
        },
        headers=headers
    )
    assert good_verify_res.status_code == 200
    assert good_verify_res.json()["verified"] is True

    # Check that internal order status transitioned to paid and confirmed
    order_check = (await async_client.get(f"/api/v1/orders/{order['id']}", headers=headers)).json()
    assert order_check["payment_status"] == "paid"
    assert order_check["status"] == "confirmed"

    # 3. Idempotent re-execution
    replay_res = await async_client.post(
        "/api/v1/checkout/razorpay/verify",
        json={
            "razorpay_order_id": rzp_order_id,
            "razorpay_payment_id": rzp_payment_id,
            "razorpay_signature": valid_sig,
            "order_id": order["id"]
        },
        headers=headers
    )
    assert replay_res.status_code == 200

@pytest.mark.asyncio
async def test_razorpay_webhook_verification_and_replay_protection(async_client):
    """
    F-01: Raw request body HMAC-SHA256 webhook signature verification and replay prevention.
    """
    event_payload = {
        "event_id": "evt_test_unique_001",
        "event": "payment.captured",
        "payload": {
            "payment": {
                "entity": {
                    "id": "pay_test_webhook_01",
                    "order_id": "order_webhook_01",
                    "amount": 500000,
                    "status": "captured"
                }
            }
        }
    }
    raw_bytes = json.dumps(event_payload).encode("utf-8")

    # 1. Invalid signature rejected
    bad_res = await async_client.post(
        "/api/v1/checkout/razorpay/webhook",
        content=raw_bytes,
        headers={"x-razorpay-signature": "bogus_signature", "Content-Type": "application/json"}
    )
    assert bad_res.status_code == 400

    # 2. Valid signature accepted
    valid_sig = hmac.new(
        settings.RAZORPAY_WEBHOOK_SECRET.encode("utf-8"),
        raw_bytes,
        hashlib.sha256
    ).hexdigest()

    good_res = await async_client.post(
        "/api/v1/checkout/razorpay/webhook",
        content=raw_bytes,
        headers={"x-razorpay-signature": valid_sig, "Content-Type": "application/json"}
    )
    assert good_res.status_code == 200
    assert good_res.json()["status"] == "success"

    # 3. Replay protection (duplicate event ignored)
    replay_res = await async_client.post(
        "/api/v1/checkout/razorpay/webhook",
        content=raw_bytes,
        headers={"x-razorpay-signature": valid_sig, "Content-Type": "application/json"}
    )
    assert replay_res.status_code == 200
    assert replay_res.json()["status"] == "duplicate"

@pytest.mark.asyncio
async def test_order_state_machine_invalid_transitions(async_client):
    """
    F-11: Order state machine rejects invalid transitions.
    """
    admin_tok = (await async_client.post(
        "/api/v1/auth/token", json={"email": "admin@buildmart.dev", "role": "admin"}
    )).json()["access_token"]
    admin_headers = {"Authorization": f"Bearer {admin_tok}"}

    prod = (await async_client.get("/api/v1/products?limit=1")).json()[0]
    order = (await async_client.post(
        "/api/v1/orders",
        json={"delivery_address": {"city": "Hyderabad"}, "payment_method": "cod", "items": [{"productId": prod["id"], "quantity": 1}]},
        headers=admin_headers
    )).json()

    # Cancel order
    cancel_res = await async_client.post(f"/api/v1/orders/{order['id']}/cancel", headers=admin_headers)
    assert cancel_res.status_code == 200
    assert cancel_res.json()["status"] == "cancelled"

    # Attempt to transition cancelled order to delivered -> 400 Bad Request
    invalid_res = await async_client.put(
        f"/api/v1/orders/{order['id']}/status",
        json={"status": "delivered"},
        headers=admin_headers
    )
    assert invalid_res.status_code == 400
    assert "invalid state transition" in invalid_res.json()["detail"].lower()

def test_production_config_fail_fast():
    """
    F-07 & F-08: Fail-fast validation in production mode.
    """
    with pytest.raises(ValueError, match="FATAL CONFIG ERROR: Production mode requires a secure SECRET_KEY"):
        Settings(
            ENVIRONMENT="production",
            SECRET_KEY="buildmart-dev-secret-key-at-least-32-chars-long",
            DEBUG=False
        )

    with pytest.raises(ValueError, match="DEBUG must be set to False in production"):
        Settings(
            ENVIRONMENT="production",
            SECRET_KEY="a-very-long-production-key-with-strictly-valid-chars-123456",
            DEBUG=True
        )
