# ADR 0003: Server-Authoritative Procurement, Statutory GST Invariants, and Payment Integrity

## Status
Accepted

## Date
2026-11-03

## Context
Commercial construction procurement transactions involve high capital values ranging from thousands to millions of rupees. Material prices fluctuate with spot market rates (e.g., steel rebar spot prices, cement carrier freight tariffs). Clients (mobile applications, web frontends, and external third-party integrations) operate in untrusted environments where tampering with line item unit prices, quantities, discount codes, or tax liabilities is an active attack vector.

Furthermore, statutory compliance under Indian Goods and Services Tax (GST) mandates exact 18% tax calculation on taxable construction goods with explicit subtotal, tax amount, and grand total accounting ledgers.

## Decision
We enforce a strict Server-Authoritative Procurement architecture across all order, quotation, and checkout workflows:

1. **Zero Client Trust for Pricing and Taxes**:
   - Client applications only transmit product identifiers (`product_id`) and desired integer quantities (`quantity`).
   - The backend service queries the authoritative database record to resolve the current active unit price.
   - Client-provided prices, totals, or tax amounts in API requests are strictly rejected or ignored.

2. **Statutory 18% GST Invariant**:
   - The subtotal is computed as:
     $$\text{subtotal} = \sum (\text{item\_price}_i \times \text{quantity}_i)$$
   - The statutory 18% GST tax is computed server-side:
     $$\text{tax\_amount} = \text{round}(\text{subtotal} \times 0.18, 2)$$
   - The grand total is derived deterministically:
     $$\text{total\_amount} = \text{subtotal} + \text{tax\_amount} + \text{delivery\_fee}$$

3. **Cryptographic Payment Integrity via Constant-Time HMAC-SHA256**:
   - Payment order creation delegates to Razorpay's API from the backend service.
   - Payment capture confirmations require:
     $$\text{expected\_signature} = \text{HMAC-SHA256}(\text{order\_id} + "|" + \text{payment\_id}, \text{RAZORPAY\_KEY\_SECRET})$$
   - Signatures are verified using constant-time string comparison (`hmac.compare_digest`) to prevent timing side-channel attacks.
   - Webhook events require idempotency keys and state machine transitions preventing double-crediting or duplicate fulfillment.

## Invariants and Guardrails
- **Immutable Order Ledgers**: Once an order transitions to `confirmed` or `completed`, its line items and price snapshots cannot be mutated.
- **Stock Decrement Synchronization**: Inventory stock decrements are verified and reserved within an atomic database transaction during order confirmation.
- **Role Invariant**: Public registration endpoints assign the `buyer` role unconditionally. Administrative privilege elevation requires direct database intervention or authenticated superadmin authorization.

## Alternatives Considered
- **Client-Side Cart Totaling**: Transmitting total cart amounts from client to payment gateways opens catastrophic price tampering vulnerabilities (e.g., placing an order with manipulated 1 rupee unit prices).
- **External Third-Party Tax Engine**: Heavy latency and recurring recurring overhead for static 18% standard construction supplies GST rates.

## Consequences
- **Positive**:
  - Elimination of financial tampering, price spoofing, and tax evasion vectors.
  - Strict compliance with statutory Indian GST accounting standards.
  - Resilient idempotent payment verification with zero double-settlement risk.
- **Negative**:
  - Requires network roundtrip to recalculate order breakdowns when cart items change.
  - Backend must maintain high availability for real-time quotation generation.

## References
- Payment Order Verification: [services/api/app/api/v1/orders.py](../../services/api/app/api/v1/orders.py)
- Payment Router and Webhooks: [services/api/app/api/v1/payments.py](../../services/api/app/api/v1/payments.py)
- Order Models and Schemas: [services/api/app/models/order.py](../../services/api/app/models/order.py)
- Wiki Documentation: [Payments-and-Orders.md](../wiki/Payments-and-Orders.md)
