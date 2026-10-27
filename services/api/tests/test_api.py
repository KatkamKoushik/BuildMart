import pytest

@pytest.mark.asyncio
async def test_health_check(async_client):
    response = await async_client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data

@pytest.mark.asyncio
async def test_categories_endpoint(async_client):
    response = await async_client.get("/api/v1/categories")
    assert response.status_code == 200
    categories = response.json()
    assert len(categories) >= 10
    cement = next((c for c in categories if c["id"] == "cement"), None)
    assert cement is not None
    assert cement["name"] == "Cement"

@pytest.mark.asyncio
async def test_products_list_and_filter(async_client):
    # Test all products
    response = await async_client.get("/api/v1/products?limit=20")
    assert response.status_code == 200
    products = response.json()
    assert len(products) > 0

    # Test category filter
    cat_response = await async_client.get("/api/v1/products?category_id=cement")
    assert cat_response.status_code == 200
    cement_products = cat_response.json()
    assert len(cement_products) > 0
    for prod in cement_products:
        assert prod["category_id"] == "cement"

    # Test search query
    search_response = await async_client.get("/api/v1/products?q=cement")
    assert search_response.status_code == 200
    search_results = search_response.json()
    assert len(search_results) > 0

@pytest.mark.asyncio
async def test_cart_workflow(async_client):
    # 1. Clear cart
    await async_client.delete("/api/v1/cart")

    # 2. Get first product
    prod_res = await async_client.get("/api/v1/products?limit=1")
    products = prod_res.json()
    assert len(products) > 0
    test_prod = products[0]

    # 3. Add to cart
    add_res = await async_client.post(
        "/api/v1/cart/items",
        json={"product_id": test_prod["id"], "quantity": 2}
    )
    assert add_res.status_code == 200
    cart_data = add_res.json()
    assert cart_data["total_count"] == 2
    assert len(cart_data["items"]) == 1
    assert cart_data["subtotal"] == round(test_prod["price"] * 2, 2)

    # 4. Update cart quantity
    item_id = cart_data["items"][0]["id"]
    upd_res = await async_client.put(
        f"/api/v1/cart/items/{item_id}",
        json={"quantity": 3}
    )
    assert upd_res.status_code == 200
    updated_cart = upd_res.json()
    assert updated_cart["total_count"] == 3

    # 5. Remove item
    del_res = await async_client.delete(f"/api/v1/cart/items/{item_id}")
    assert del_res.status_code == 200
    empty_cart = del_res.json()
    assert empty_cart["total_count"] == 0

@pytest.mark.asyncio
async def test_order_creation_and_history(async_client):
    # Add product to cart first
    prod_res = await async_client.get("/api/v1/products?limit=1")
    test_prod = prod_res.json()[0]
    await async_client.post("/api/v1/cart/items", json={"product_id": test_prod["id"], "quantity": 1})

    # Create order
    order_payload = {
        "delivery_address": {
            "fullName": "Test Site Manager",
            "addressLine1": "Plot 100, Financial District",
            "city": "Hyderabad",
            "state": "Telangana",
            "postalCode": "500032",
            "phone": "9876543210"
        },
        "payment_method": "cod"
    }
    order_res = await async_client.post("/api/v1/orders", json=order_payload)
    assert order_res.status_code == 201
    order = order_res.json()
    assert order["status"] == "confirmed"
    assert order["order_number"].startswith("BM-")

    # List orders
    list_res = await async_client.get("/api/v1/orders")
    assert list_res.status_code == 200
    orders_list = list_res.json()
    assert len(orders_list) > 0
    assert any(o["id"] == order["id"] for o in orders_list)

@pytest.mark.asyncio
async def test_quote_request_and_pdf(async_client):
    quote_payload = {
        "customer_name": "ABC Builders",
        "email": "procurement@abcbuilders.com",
        "phone": "9876543210",
        "project_name": "Tower A Construction",
        "delivery_pincode": "500081",
        "items": [
            {"title": "Ultratech Super Cement (50kg bags)", "quantity": 200, "unit": "bags"},
            {"title": "Tata Tiscon 12mm TMT Steel Rods", "quantity": 50, "unit": "rods"}
        ]
    }
    create_res = await async_client.post("/api/v1/quotes", json=quote_payload)
    assert create_res.status_code == 200
    quote = create_res.json()
    assert quote["quote_number"].startswith("QT-")

    # Download PDF
    pdf_res = await async_client.get(f"/api/v1/quotes/{quote['id']}/pdf")
    assert pdf_res.status_code == 200
    assert pdf_res.headers["content-type"] == "application/pdf"
    assert len(pdf_res.content) > 500
