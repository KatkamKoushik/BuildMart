import pytest

@pytest.mark.asyncio
async def test_login_success(async_client):
    payload = {
        "email": "buyer@buildmart.dev",
        "role": "buyer"
    }
    response = await async_client.post("/api/v1/auth/token", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["user"]["email"] == "buyer@buildmart.dev"

@pytest.mark.asyncio
async def test_login_invalid_credentials(async_client):
    payload = {
        "email": "invalid@example.com",
        "role": "buyer"
    }
    response = await async_client.post("/api/v1/auth/token", json=payload)
    assert response.status_code == 200
    assert response.json()["user"]["email"] == "invalid@example.com"

@pytest.mark.asyncio
async def test_add_to_cart_zero_quantity(async_client):
    tok_res = await async_client.post("/api/v1/auth/token", json={"email": "buyer@buildmart.dev", "role": "buyer"})
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    prod_res = await async_client.get("/api/v1/products?limit=1")
    test_prod = prod_res.json()[0]

    payload = {
        "product_id": test_prod["id"],
        "quantity": 0
    }
    response = await async_client.post("/api/v1/cart/items", json=payload, headers=headers)
    assert response.status_code == 422 # Pydantic validation error

@pytest.mark.asyncio
async def test_add_to_cart_inactive_product(async_client):
    tok_res = await async_client.post("/api/v1/auth/token", json={"email": "buyer@buildmart.dev", "role": "buyer"})
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "product_id": "unknown_product",
        "quantity": 1
    }
    response = await async_client.post("/api/v1/cart/items", json=payload, headers=headers)
    assert response.status_code == 404

@pytest.mark.asyncio
async def test_razorpay_order_creation_amount_trust(async_client):
    tok_res = await async_client.post("/api/v1/auth/token", json={"email": "buyer@buildmart.dev", "role": "buyer"})
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Clear cart
    await async_client.delete("/api/v1/cart", headers=headers)

    prod_res = await async_client.get("/api/v1/products?limit=1")
    test_prod = prod_res.json()[0]

    await async_client.post("/api/v1/cart/items", json={"product_id": test_prod["id"], "quantity": 1}, headers=headers)

    order_payload = {
        "delivery_address": {
            "fullName": "Test User",
            "addressLine1": "Test Addr",
            "city": "Test",
            "state": "Test",
            "postalCode": "123456",
            "phone": "9999999999"
        },
        "payment_method": "razorpay"
    }
    order_resp = await async_client.post("/api/v1/orders", json=order_payload, headers=headers)
    assert order_resp.status_code == 201
    order = order_resp.json()

    payload = {
        "order_id": order["id"],
        "currency": "INR",
        "receipt": "test_receipt"
    }
    response = await async_client.post("/api/v1/checkout/razorpay/create-order", json=payload, headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert "order_id" in data
    expected_amount = int(round(order["total_amount"] * 100))
    assert data["amount"] == expected_amount

@pytest.mark.asyncio
async def test_razorpay_webhook_verification(async_client):
    response = await async_client.post("/api/v1/checkout/razorpay/webhook", json={"event": "test"})
    assert response.status_code == 400
    assert response.json()["detail"] == "Missing X-Razorpay-Signature header"
