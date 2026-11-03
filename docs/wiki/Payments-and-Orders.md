# Payments and Order Management Lifecycle

This document describes the commercial transaction architecture, Razorpay payment processing, cryptographic signature verification, webhook deduplication, and the formal order state machine.

Primary Source Files:
- [services/api/app/api/v1/checkout.py](../../services/api/app/api/v1/checkout.py)
- [services/api/app/api/v1/orders.py](../../services/api/app/api/v1/orders.py)
- [services/api/app/api/v1/quotes.py](../../services/api/app/api/v1/quotes.py)
- [services/api/app/models/models.py](../../services/api/app/models/models.py)
- [apps/web/src/app/checkout](../../apps/web/src/app/checkout)

---

## Order Lifecycle State Machine

Orders transition through formal state boundaries with strict transition guard rules:

```mermaid
stateDiagram-v2
    [*] --> Pending: Customer initiates checkout (Order Created)
    Pending --> Confirmed: Payment Verified (Razorpay HMAC-SHA256 / Webhook)
    Pending --> Cancelled: Payment Failed or Customer Abandons
    Confirmed --> Processing: Yard acknowledges order & picks inventory
    Processing --> Dispatched: Material loaded & delivery vehicle en route
    Dispatched --> Delivered: Delivery confirmed at site gate
    Confirmed --> Cancelled: Buyer cancels prior to yard loading
    Processing --> Cancelled: Admin override or stock discrepancy
    Delivered --> [*]
    Cancelled --> [*]
```

### Transition Guard Rules:
- **Pending -> Confirmed**: Requires valid Razorpay payment signature or verified Cash-on-Delivery approval.
- **Confirmed -> Cancelled**: Allowed if logistics status is not yet marked `dispatched`.
- **Dispatched -> Cancelled**: Forbidden. Once logistics fleet is in transit, cancellation must be processed via physical return protocol.
- **Delivered**: Final terminal state. Generates final GST tax invoice.

---

## Payment Verification Sequence (Razorpay HMAC-SHA256)

Payment authenticity is guaranteed through dual-channel verification (synchronous client callback and asynchronous gateway webhook):

```mermaid
sequenceDiagram
    autonumber
    actor Buyer as Contractor / Builder
    participant Frontend as Web / Mobile Frontend
    participant APIGateway as FastAPI Checkout Router
    participant RazorpayAPI as Razorpay Payment Gateway
    participant Database as PostgreSQL Database

    Buyer->>Frontend: Click "Proceed to Payment"
    Frontend->>APIGateway: POST /api/v1/checkout/razorpay/create-order {amount, currency}
    APIGateway->>RazorpayAPI: Create Gateway Order (orders.create)
    RazorpayAPI-->>APIGateway: Gateway Order {id: "order_xyz123", amount}
    APIGateway-->>Frontend: 200 OK {razorpay_order_id, key_id, amount}

    Buyer->>Frontend: Complete Card / UPI / NetBanking payment
    Frontend->>RazorpayAPI: Authorize transaction
    RazorpayAPI-->>Frontend: Payment Success {razorpay_payment_id, razorpay_signature}

    Frontend->>APIGateway: POST /api/v1/checkout/razorpay/verify<br/>{order_id, payment_id, signature, delivery_address}
    APIGateway->>APIGateway: Compute HMAC-SHA256(order_id + "|" + payment_id, SECRET)
    APIGateway->>APIGateway: Compare with razorpay_signature using hmac.compare_digest
    alt Signature Matches
        APIGateway->>Database: Persist Order (Status: Confirmed, Payment: Paid)
        APIGateway->>Database: Deduct Cart Items
        APIGateway-->>Frontend: 200 OK {order_number, status: "confirmed"}
    else Signature Invalid
        APIGateway-->>Frontend: 400 Bad Request (Invalid signature)
    end

    opt Asynchronous Webhook Reconciliation
        RazorpayAPI->>APIGateway: POST /api/v1/checkout/razorpay/webhook (X-Razorpay-Signature)
        APIGateway->>APIGateway: Verify raw-body HMAC signature
        APIGateway->>Database: Check webhook_events table for event_id
        alt Already Processed (Replay)
            APIGateway-->>RazorpayAPI: 200 OK (Event already processed)
        else Fresh Event
            APIGateway->>Database: Record event_id into webhook_events
            APIGateway->>Database: Reconcile order payment_status to "paid"
            APIGateway-->>RazorpayAPI: 200 OK (Processed)
        end
    end
```

---

## Statutory 18% GST Construction Tax Invariant

All order and quotation computations follow server-authoritative statutory taxation rules:

$$\text{Subtotal} = \sum_{i=1}^{n} (\text{UnitPrice}_i \times \text{Quantity}_i)$$

$$\text{GST Tax (18\%)} = \text{Subtotal} \times 0.18$$

$$\text{Delivery Fee} = \begin{cases} 0.00 & \text{if Subtotal} \ge 10{,}000 \\ 500.00 & \text{otherwise} \end{cases}$$

$$\text{Total Amount} = \text{Subtotal} + \text{GST Tax} + \text{Delivery Fee}$$

Client-submitted tax rates, discounts, or delivery fees are discarded. The server computes all values against authoritative database prices and inserts frozen price snapshots into `order_items`.

---

## Commercial Bill of Materials (BOM) Quotations

Contractors requiring client or bank estimation approvals can submit a Bill of Materials for automated commercial quotation generation.

- **Submission Endpoint**: `POST /api/v1/quotes`
- **Dynamic PDF Compilation**: `GET /api/v1/quotes/{id}/pdf`
  - Utilizes ReportLab to compile branded, audit-ready engineering quotations.
  - Includes contractor details, project site delivery pincode, itemized materials, statutory GST breakdown, and legal terms of validity.
