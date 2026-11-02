import pytest

async def get_test_token(async_client, email: str, password: str = "DevPass123!", name: str = "Test User") -> str:
    login_res = await async_client.post("/api/v1/auth/token", json={"email": email, "password": password})
    if login_res.status_code == 200:
        return login_res.json()["access_token"]
    reg_res = await async_client.post("/api/v1/auth/register", json={
        "name": name,
        "email": email,
        "password": password
    })
    if reg_res.status_code == 201:
        return reg_res.json()["access_token"]
    raise RuntimeError(f"Could not obtain token for {email}: {login_res.text} / {reg_res.text}")


@pytest.mark.asyncio
async def test_login_success(async_client):
    payload = {
        "email": "buyer@buildmart.dev",
        "password": "DevPass123!",
    }
    response = await async_client.post("/api/v1/auth/token", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["user"]["email"] == "buyer@buildmart.dev"


@pytest.mark.asyncio
async def test_login_missing_password_rejected(async_client):
    """
    P0: An email address is not proof of identity. Missing password must be rejected with 401.
    """
    payload = {"email": "buyer@buildmart.dev"}
    response = await async_client.post("/api/v1/auth/token", json=payload)
    assert response.status_code == 401
    assert "password is required" in response.json().get("detail", "").lower()


@pytest.mark.asyncio
async def test_login_wrong_password_rejected(async_client):
    """
    P0: Existing accounts must never receive a token without proving control with valid password.
    """
    payload = {
        "email": "buyer@buildmart.dev",
        "password": "IncorrectPassword123!"
    }
    response = await async_client.post("/api/v1/auth/token", json=payload)
    assert response.status_code == 401
    assert "invalid email or password" in response.json().get("detail", "").lower()


@pytest.mark.asyncio
async def test_registration_and_privilege_escalation_defense(async_client):
    """
    P0: Public registration must not accept or set admin, seller, or vendor from client input.
    Server unconditionally assigns least-privileged 'buyer' role.
    """
    payload = {
        "name": "Malicious User",
        "email": "attacker@evilcorp.com",
        "password": "SecurePassword123!",
        "role": "admin"  # Attempt to self-assign admin
    }
    reg_res = await async_client.post("/api/v1/auth/register", json=payload)
    assert reg_res.status_code == 201
    user = reg_res.json()["user"]
    # Role must be strictly 'buyer', ignoring client input
    assert user["role"] == "buyer"

    # Attacker cannot access admin endpoints
    token = reg_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    admin_res = await async_client.get("/api/v1/admin/metrics", headers=headers)
    assert admin_res.status_code == 403


@pytest.mark.asyncio
async def test_registration_weak_password_rejected(async_client):
    """
    P0: Weak passwords must be rejected at schema validation.
    """
    payload = {
        "name": "Weak User",
        "email": "weak@buildmart.dev",
        "password": "weak"  # Too short and lacking complexity
    }
    reg_res = await async_client.post("/api/v1/auth/register", json=payload)
    assert reg_res.status_code == 422


@pytest.mark.asyncio
async def test_password_reset_flow(async_client):
    """
    P0: Verified password reset flow with signed token.
    """
    token_req = await async_client.post(
        "/api/v1/auth/password-reset-request",
        json={"email": "buyer@buildmart.dev"}
    )
    assert token_req.status_code == 200
    reset_token = token_req.json().get("reset_token")
    assert reset_token is not None

    # Reset password
    confirm_res = await async_client.post(
        "/api/v1/auth/password-reset",
        json={"token": reset_token, "new_password": "NewDevPass123!"}
    )
    assert confirm_res.status_code == 200

    # Login with new password succeeds
    login_new = await async_client.post(
        "/api/v1/auth/token",
        json={"email": "buyer@buildmart.dev", "password": "NewDevPass123!"}
    )
    assert login_new.status_code == 200

    # Reset back to default password for subsequent test stability
    token_req2 = await async_client.post(
        "/api/v1/auth/password-reset-request",
        json={"email": "buyer@buildmart.dev"}
    )
    await async_client.post(
        "/api/v1/auth/password-reset",
        json={"token": token_req2.json()["reset_token"], "new_password": "DevPass123!"}
    )


@pytest.mark.asyncio
async def test_add_to_cart_zero_quantity(async_client):
    token = await get_test_token(async_client, "buyer@buildmart.dev")
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
    token = await get_test_token(async_client, "buyer@buildmart.dev")
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
    P1: Client cannot tamper with order amount.
    Amount is strictly determined server-side from order total.
    """
    token = await get_test_token(async_client, "checkout_tester@buildmart.dev", name="Checkout Tester")
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

    # Client attempts to send manipulated amount 1.0 (Rs. 1)
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
    P1: User B cannot create payment intent for User A's order.
    """
    token_a = await get_test_token(async_client, "owner_a@buildmart.dev", name="Owner A")
    headers_a = {"Authorization": f"Bearer {token_a}"}

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
    token_b = await get_test_token(async_client, "attacker_b@buildmart.dev", name="Attacker B")
    headers_b = {"Authorization": f"Bearer {token_b}"}

    response = await async_client.post(
        "/api/v1/checkout/razorpay/create-order",
        json={"order_id": order["id"]},
        headers=headers_b,
    )
    assert response.status_code == 403
    assert "access forbidden" in response.json()["detail"].lower()


@pytest.mark.asyncio
async def test_add_saved_address(async_client):
    token = await get_test_token(async_client, "addr_user@buildmart.dev", name="Address User")
    headers = {"Authorization": f"Bearer {token}"}

    res_me = await async_client.get("/api/v1/auth/me", headers=headers)
    assert res_me.status_code == 200
    initial_addr_count = len(res_me.json().get("saved_addresses") or [])

    new_address = {
        "fullName": "Koushik Katkam",
        "addressLine1": "Plot 104, Mega Hills",
        "city": "Hyderabad",
        "state": "Telangana",
        "postalCode": "500081",
        "phone": "9876543210",
        "isDefault": True,
    }
    response = await async_client.post("/api/v1/auth/address", json=new_address, headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert len(data["saved_addresses"]) == initial_addr_count + 1

    added = data["saved_addresses"][-1]
    assert added["fullName"] == "Koushik Katkam"
    assert added["postalCode"] == "500081"
    assert added["isDefault"] is True

    # Add second address with isDefault=True, should unset first default
    new_address2 = {
        "fullName": "Koushik Office",
        "addressLine1": "Cyber Towers, Hitec City",
        "city": "Hyderabad",
        "state": "Telangana",
        "postalCode": "500081",
        "phone": "9876543210",
        "isDefault": True,
    }
    response2 = await async_client.post("/api/v1/auth/address", json=new_address2, headers=headers)
    assert response2.status_code == 200
    data2 = response2.json()
    assert len(data2["saved_addresses"]) == initial_addr_count + 2

    matching_initial = [a for a in data2["saved_addresses"] if a["fullName"] == "Koushik Katkam"][0]
    assert matching_initial["isDefault"] is False
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
    token = await get_test_token(async_client, "cart_zero_user@buildmart.dev", name="Cart Zero User")
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
    token = await get_test_token(async_client, "cart_neg_user@buildmart.dev", name="Cart Neg User")
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

    token = await get_test_token(async_client, "provider_error_tester@buildmart.dev", name="Provider Error Tester")
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


@pytest.mark.asyncio
async def test_quote_request_validation_errors(async_client):
    # 1. Non-positive quantity should fail with 422
    payload_bad_qty = {
        "customer_name": "Test Builder",
        "email": "test@builder.com",
        "phone": "9876543210",
        "delivery_pincode": "500081",
        "items": [{"title": "Steel Rods", "quantity": 0, "unit": "tonnes"}]
    }
    res = await async_client.post("/api/v1/quotes", json=payload_bad_qty)
    assert res.status_code == 422

    # 2. Invalid pincode should fail with 422
    payload_bad_pin = {
        "customer_name": "Test Builder",
        "email": "test@builder.com",
        "phone": "9876543210",
        "delivery_pincode": "12345",  # 5 digits instead of 6
        "items": [{"title": "Steel Rods", "quantity": 5, "unit": "tonnes"}]
    }
    res = await async_client.post("/api/v1/quotes", json=payload_bad_pin)
    assert res.status_code == 422

    # 3. Invalid phone format (<10 digits) should fail with 422
    payload_bad_phone = {
        "customer_name": "Test Builder",
        "email": "test@builder.com",
        "phone": "98765",
        "delivery_pincode": "500081",
        "items": [{"title": "Steel Rods", "quantity": 5, "unit": "tonnes"}]
    }
    res = await async_client.post("/api/v1/quotes", json=payload_bad_phone)
    assert res.status_code == 422

    # 4. Empty items list should fail with 422
    payload_empty_items = {
        "customer_name": "Test Builder",
        "email": "test@builder.com",
        "phone": "9876543210",
        "delivery_pincode": "500081",
        "items": []
    }
    res = await async_client.post("/api/v1/quotes", json=payload_empty_items)
    assert res.status_code == 422


@pytest.mark.asyncio
async def test_quote_request_catalog_price_estimation(async_client):
    prod_res = await async_client.get("/api/v1/products?limit=1")
    assert prod_res.status_code == 200
    prod = prod_res.json()[0]

    quote_payload = {
        "customer_name": "Enterprise Contracting",
        "email": "procurement@contracting.com",
        "phone": "9876543210",
        "delivery_pincode": "500081",
        "items": [
            {
                "product_id": prod["id"],
                "title": prod["title"],
                "quantity": 4,
                "unit": prod["unit"]
            }
        ]
    }
    create_res = await async_client.post("/api/v1/quotes", json=quote_payload)
    assert create_res.status_code == 200
    quote = create_res.json()
    expected_estimate = float(prod["price"] * 4)
    assert abs(quote["estimated_total"] - expected_estimate) < 0.01
