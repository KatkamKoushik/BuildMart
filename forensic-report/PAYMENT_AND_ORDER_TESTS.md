# BuildMart Payment & Order Lifecycle Verification Report

This report presents the implementation and automated test evidence for BuildMart's financial calculations, Razorpay integration, payment verification, order state machine, and webhook handling.

---

## 1. Financial Calculation & Pricing Architecture (F-13)

### Server-Authoritative Pricing Rules
All amounts that determine payable balances are computed exclusively by the backend in [services/api/app/api/v1/orders.py](file:///d:/buildmart/services/api/app/api/v1/orders.py#L40-L100):

1. Unit Price Lookup:
   - For every item in the order or cart, the unit price is queried directly from the active `Product` database record. Any client-submitted `price` field in the request payload is ignored.
2. Quantity Validation:
   - Quantities must be positive integers (`qty > 0`). Non-positive quantities (`quantity: 0` or `quantity: -5`) are rejected with HTTP 422 Unprocessable Entity.
3. Goods and Services Tax (GST):
   - Standard Indian GST for construction and building materials is applied at 18%:
     `tax = round(subtotal * 0.18, 2)`
4. Tiered Delivery Fee Policy:
   - Orders with a subtotal of Rs. 5,000 or greater qualify for free heavy material site delivery (`delivery_fee = 0.0`).
   - Orders below Rs. 5,000 incur a standard flat site delivery logistics fee of Rs. 250 (`delivery_fee = 250.0`).
5. Authoritative Payable Total:
   - `total_amount = round(subtotal + tax + delivery_fee, 2)`

---

## 2. Order Lifecycle Finite State Machine (F-11)

### State Definitions
- `pending`: Initial state for online (Razorpay/UPI/NetBanking) orders awaiting server-side verification.
- `confirmed`: Order verified (online payment captured or Cash on Delivery order validated).
- `processing`: Warehouse fulfillment and consignment packing initiated.
- `dispatched`: Materials loaded on delivery vehicle and en route to construction site.
- `delivered`: Materials received at site and delivery receipt acknowledged. Terminal state.
- `cancelled`: Order terminated. Permissible only from `pending` or `confirmed`. Terminal state.

### State Transition Validation Matrix
```
Current State   | Allowed Next States            | Disallowed Transitions
----------------+--------------------------------+------------------------------------
pending         | confirmed, cancelled           | processing, dispatched, delivered
confirmed       | processing, cancelled          | delivered, pending
processing      | dispatched, cancelled          | pending, confirmed
dispatched      | delivered                      | pending, confirmed, cancelled
delivered       | (None - Terminal)              | Any transition rejected (HTTP 400)
cancelled       | (None - Terminal)              | Any transition rejected (HTTP 400)
```

Implementation location: [services/api/app/api/v1/orders.py](file:///d:/buildmart/services/api/app/api/v1/orders.py#L20-L28).

---

## 3. Razorpay Payment Verification & Webhook Handling (F-01)

### Checkout Signature Verification
Endpoint: `POST /api/v1/checkout/razorpay/verify`
1. Request payload contains: `razorpay_order_id`, `razorpay_payment_id`, `razorpay_signature`, and `order_id`.
2. Signature payload constructed as: `f"{razorpay_order_id}|{razorpay_payment_id}"`.
3. Expected HMAC calculated:
   ```python
   expected = hmac.new(settings.RAZORPAY_KEY_SECRET.encode(), payload.encode(), hashlib.sha256).hexdigest()
   ```
4. Compared using constant-time `hmac.compare_digest`. Mismatch raises HTTP 400 Bad Request.
5. On success: matching database order transitions to `payment_status="paid"`, `status="confirmed"`, and records `razorpay_payment_id`.
6. Subsequent calls with identical credentials return HTTP 200 without duplicate state modification (idempotent).

### Webhook Raw Body Verification & Replay Protection
Endpoint: `POST /api/v1/checkout/razorpay/webhook`
1. Header `x-razorpay-signature` extracted.
2. Raw body bytes read directly from HTTP connection (`await request.body()`).
3. Expected HMAC computed against raw bytes using `settings.RAZORPAY_WEBHOOK_SECRET`.
4. Invalid signature returns HTTP 400 Bad Request.
5. Replay Protection: `WebhookEvent` table queried for `event_id`. If previously processed, returns:
   ```json
   { "status": "duplicate", "event_id": "...", "message": "Webhook event already processed" }
   ```
6. Handled events:
   - `payment.captured` / `order.paid`: Updates order to `payment_status="paid"`, `status="confirmed"`.
   - `payment.failed`: Updates order to `payment_status="failed"`.

---

## 4. Test Evidence & Automated Execution

The test suite in [services/api/tests/test_security_and_lifecycle.py](file:///d:/buildmart/services/api/tests/test_security_and_lifecycle.py) executes automated tests for all scenarios:

| Test Name | Verified Scenario | Expected Result | Actual Outcome |
| :--- | :--- | :--- | :--- |
| `test_server_authoritative_calculations_and_tampering` | Negative quantity submitted (`quantity: -5`) | HTTP 422 Unprocessable Entity | PASSED |
| `test_server_authoritative_calculations_and_tampering` | Subtotal, 18% GST, Rs. 250 fee, pending status | Total matches math; payment_status="pending" | PASSED |
| `test_razorpay_signature_verification_and_tampering` | Forged/tampered signature submitted | HTTP 400 Bad Request | PASSED |
| `test_razorpay_signature_verification_and_tampering` | Valid HMAC-SHA256 signature submitted | HTTP 200 OK; order set to paid/confirmed | PASSED |
| `test_razorpay_signature_verification_and_tampering` | Replay verification request | HTTP 200 OK; idempotent response | PASSED |
| `test_razorpay_webhook_verification_and_replay_protection` | Webhook with forged signature | HTTP 400 Bad Request | PASSED |
| `test_razorpay_webhook_verification_and_replay_protection` | Valid raw-body webhook `payment.captured` | HTTP 200 OK; event processed | PASSED |
| `test_razorpay_webhook_verification_and_replay_protection` | Replay identical webhook event ID | HTTP 200 OK; status="duplicate" | PASSED |
| `test_order_state_machine_invalid_transitions` | Transition from `cancelled` to `delivered` | HTTP 400 Bad Request | PASSED |
