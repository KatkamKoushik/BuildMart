import pytest


@pytest.mark.asyncio
async def test_login_success(async_client):
    payload = {
        "email": "buyer@buildmart.dev",
        "role": "buyer",
    }
    response = await async_client.post("/api/v1/auth/token", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["user"]["email"] == "buyer@buildmart.dev"


@pytest.mark.asyncio
async def test_add_to_cart_zero_quantity(async_client):
    tok_res = await async_client.post(
        "/api/v1/auth/token", json={"email": "buyer@buildmart.dev", "role": "buyer"}
    )
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    prod_res = await async_client.get("/api/v1/products?limit=1")
    test_prod = prod_res.json()[0]

    payload = {
        "product_id": test_prod["id"],
        "quantity": 0,
    }
    response = await async_client.post("/api/v1/cart/items", json=payload, headers=headers)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_add_to_cart_nonexistent_product(async_client):
    tok_res = await async_client.post(
        "/api/v1/auth/token", json={"email": "buyer@buildmart.dev", "role": "buyer"}
    )
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "product_id": "nonexistent_prod_xyz",
        "quantity": 1,
    }
    response = await async_client.post("/api/v1/cart/items", json=payload, headers=headers)
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_razorpay_order_creation_amount_trust(async_client):
    """
    Verifies that client cannot tamper with order amount.
    Amount is strictly determined server-side from order total.
    """
    tok_res = await async_client.post(
        "/api/v1/auth/token", json={"email": "checkout_tester@buildmart.dev", "role": "buyer"}
    )
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Clear cart
    await async_client.delete("/api/v1/cart", headers=headers)

    prod_res = await async_client.get("/api/v1/products?limit=1")
    test_prod = prod_res.json()[0]

    await async_client.post(
        "/api/v1/cart/items", json={"product_id": test_prod["id"], "quantity": 1}, headers=headers
    )

    order_payload = {
        "delivery_address": {
            "fullName": "Checkout Tester",
            "addressLine1": "Plot 10, HITEC City",
            "city": "Hyderabad",
            "state": "Telangana",
            "postalCode": "500081",
            "phone": "9999999999",
        },
        "payment_method": "razorpay",
    }
    order_resp = await async_client.post("/api/v1/orders", json=order_payload, headers=headers)
    assert order_resp.status_code == 201
    order = order_resp.json()

    # Client sends manipulated amount 1.0 (Rs. 1)
    payload = {
        "order_id": order["id"],
        "amount": 1.0,
        "currency": "INR",
        "receipt": "test_receipt",
    }
    response = await async_client.post(
        "/api/v1/checkout/razorpay/create-order", json=payload, headers=headers
    )
    assert response.status_code == 200
    data = response.json()
    assert "order_id" in data
    # Server must ignore client 1.0 and use authoritative order.total_amount
    expected_amount = int(round(order["total_amount"] * 100))
    assert data["amount"] == expected_amount


@pytest.mark.asyncio
async def test_razorpay_order_creation_cross_user_denied(async_client):
    """
    Verifies that User B cannot create payment intent for User A's order.
    """
    tok_res_a = await async_client.post(
        "/api/v1/auth/token", json={"email": "owner_a@buildmart.dev", "role": "buyer"}
    )
    headers_a = {"Authorization": f"Bearer {tok_res_a.json()['access_token']}"}

    prod_res = await async_client.get("/api/v1/products?limit=1")
    test_prod = prod_res.json()[0]

    order_resp = await async_client.post(
        "/api/v1/orders",
        json={
            "items": [{"product_id": test_prod["id"], "quantity": 1}],
            "delivery_address": {
                "fullName": "Owner A",
                "addressLine1": "Street 1",
                "city": "Hyderabad",
                "state": "Telangana",
                "postalCode": "500081",
                "phone": "9876543210",
            },
            "payment_method": "razorpay",
        },
        headers=headers_a,
    )
    assert order_resp.status_code == 201
    order = order_resp.json()

    # User B tries to initiate checkout for User A's order
    tok_res_b = await async_client.post(
        "/api/v1/auth/token", json={"email": "attacker_b@buildmart.dev", "role": "buyer"}
    )
    headers_b = {"Authorization": f"Bearer {tok_res_b.json()['access_token']}"}

    response = await async_client.post(
        "/api/v1/checkout/razorpay/create-order",
        json={"order_id": order["id"]},
        headers=headers_b,
    )
    assert response.status_code == 403
    assert "access forbidden" in response.json()["detail"].lower()


@pytest.mark.asyncio
async def test_add_saved_address(async_client):
    tok_res = await async_client.post(
        "/api/v1/auth/token", json={"email": "addr_user@buildmart.dev", "role": "buyer"}
    )
    user_data = tok_res.json()["user"]
    initial_addr_count = len(user_data.get("saved_addresses") or [])
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    address_payload = {
        "fullName": "John Doe",
        "addressLine1": "123 Main St",
        "addressLine2": "Apt 4B",
        "city": "Bengaluru",
        "state": "Karnataka",
        "postalCode": "560001",
        "phone": "9876543210",
        "isDefault": True,
    }

    res = await async_client.post("/api/v1/auth/address", json=address_payload, headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert len(data["saved_addresses"]) == initial_addr_count + 1
    added_addr = data["saved_addresses"][-1]
    assert added_addr["fullName"] == "John Doe"
    assert added_addr["isDefault"] is True
    assert "id" in added_addr

    # Add second address as default
    address_payload_2 = {
        "fullName": "John Work",
        "addressLine1": "456 Tech Park",
        "city": "Bengaluru",
        "state": "Karnataka",
        "postalCode": "560045",
        "phone": "9876543210",
        "isDefault": True,
    }
    res2 = await async_client.post("/api/v1/auth/address", json=address_payload_2, headers=headers)
    assert res2.status_code == 200
    data2 = res2.json()
    assert len(data2["saved_addresses"]) == initial_addr_count + 2
    # Verify previous address is now isDefault=False and newest is isDefault=True
    assert data2["saved_addresses"][-2]["isDefault"] is False
    assert data2["saved_addresses"][-1]["isDefault"] is True


@pytest.mark.asyncio
async def test_add_saved_address_unauthenticated(async_client):
    res = await async_client.post("/api/v1/auth/address", json={
        "fullName": "Ghost",
        "addressLine1": "Nowhere",
        "city": "Unknown",
        "state": "Unknown",
        "postalCode": "000000",
        "phone": "0000000000",
    })
    assert res.status_code in [401, 403]


@pytest.mark.asyncio
async def test_update_cart_item_zero_quantity_removes_item(async_client):
    tok_res = await async_client.post(
        "/api/v1/auth/token", json={"email": "cart_zero_user@buildmart.dev", "role": "buyer"}
    )
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Clear cart first
    await async_client.delete("/api/v1/cart", headers=headers)

    prod_res = await async_client.get("/api/v1/products?limit=2")
    products = prod_res.json()
    prod_1 = products[0]
    prod_2 = products[1]

    # Add both items to cart
    await async_client.post(
        "/api/v1/cart/items", json={"product_id": prod_1["id"], "quantity": 2}, headers=headers
    )
    add_res_2 = await async_client.post(
        "/api/v1/cart/items", json={"product_id": prod_2["id"], "quantity": 3}, headers=headers
    )
    cart = add_res_2.json()
    assert len(cart["items"]) == 2

    item_1_id = cart["items"][0]["id"]
    item_2_id = cart["items"][1]["id"]

    # Update item 1 with quantity 0 -> should delete item 1
    upd_res_1 = await async_client.put(
        f"/api/v1/cart/items/{item_1_id}", json={"quantity": 0}, headers=headers
    )
    assert upd_res_1.status_code == 200
    cart_after_0 = upd_res_1.json()
    assert len(cart_after_0["items"]) == 1
    assert cart_after_0["items"][0]["id"] == item_2_id


@pytest.mark.asyncio
async def test_update_cart_item_negative_quantity_rejected(async_client):
    tok_res = await async_client.post(
        "/api/v1/auth/token", json={"email": "cart_neg_user@buildmart.dev", "role": "buyer"}
    )
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    prod_res = await async_client.get("/api/v1/products?limit=1")
    prod = prod_res.json()[0]

    add_res = await async_client.post(
        "/api/v1/cart/items", json={"product_id": prod["id"], "quantity": 1}, headers=headers
    )
    cart = add_res.json()
    item_id = cart["items"][0]["id"]

    # Update with negative quantity -> rejected with 422
    upd_res = await async_client.put(
        f"/api/v1/cart/items/{item_id}", json={"quantity": -1}, headers=headers
    )
    assert upd_res.status_code == 422


@pytest.mark.asyncio
async def test_razorpay_order_creation_provider_error(async_client, monkeypatch):
    from app.core.config import settings
    import razorpay

    class FailingOrderAPI:
        def create(self, data):
            raise Exception("Upstream connection reset by peer")

    class FailingRazorpayClient:
        def __init__(self, auth=None):
            self.order = FailingOrderAPI()

    monkeypatch.setattr(settings, "RAZORPAY_KEY_ID", "rzp_live_test_id")
    monkeypatch.setattr(settings, "RAZORPAY_KEY_SECRET", "live_secret_for_error_test")
    monkeypatch.setattr(razorpay, "Client", FailingRazorpayClient)

    tok_res = await async_client.post(
        "/api/v1/auth/token", json={"email": "provider_error_tester@buildmart.dev", "role": "buyer"}
    )
    token = tok_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    prod_res = await async_client.get("/api/v1/products?limit=1")
    test_prod = prod_res.json()[0]

    order_resp = await async_client.post(
        "/api/v1/orders",
        json={
            "items": [{"product_id": test_prod["id"], "quantity": 1}],
            "delivery_address": {
                "fullName": "Error Tester",
                "addressLine1": "Street 10",
                "city": "Hyderabad",
                "state": "Telangana",
                "postalCode": "500081",
                "phone": "9876543210",
            },
            "payment_method": "razorpay",
        },
        headers=headers,
    )
    assert order_resp.status_code == 201
    order = order_resp.json()

    response = await async_client.post(
        "/api/v1/checkout/razorpay/create-order",
        json={"order_id": order["id"]},
        headers=headers,
    )
    assert response.status_code == 502
    assert "razorpay provider error" in response.json()["detail"].lower()
