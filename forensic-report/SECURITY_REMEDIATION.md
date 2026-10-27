# BuildMart Security Remediation & Hardening Report

This report details the security architecture, threat model mitigations, credential hygiene enforcement, and data protection controls implemented across BuildMart.

---

## 1. Authentication Architecture & Token Verification (F-14)

### Baseline Gap
In the early prototype, authentication checks defaulted to an arbitrary demo buyer account whenever authorization headers were absent. This allowed direct unauthorized access to order management, cart mutations, and checkout endpoints.

### Remediated Implementation
1. Cryptographic JWT Verification:
   - Implemented standard HMAC-SHA256 JWT encoding and decoding in [services/api/app/core/security.py](file:///d:/buildmart/services/api/app/core/security.py#L25-L65).
   - Token payload includes standard claims: `sub` (user UUID), `email`, `role`, `iat` (issued at timestamp), and `exp` (24-hour expiration).
   - Any expired, unsigned, or tampered token raises HTTP 401 Unauthorized with standard `WWW-Authenticate: Bearer` headers.
2. Strict Endpoint Protection:
   - Endpoints requiring authentication depend on `require_authenticated_user`.
   - Anonymous requests to `/api/v1/orders`, `/api/v1/checkout/razorpay/create-order`, and `/api/v1/admin/*` are strictly rejected with HTTP 401.
   - Public catalog endpoints (`/api/v1/products`, `/api/v1/categories`, `/api/v1/brands`, `/api/v1/shops`, `/api/v1/banners`, `/api/v1/health`) remain accessible without credentials.

---

## 2. Server-Side Role-Based Authorization & Resource Isolation (F-02 & F-10)

### Threat Boundary Mitigation
Client applications (web browsers and mobile apps) are untrusted runtimes. Access control is enforced exclusively at the server boundary:

1. Privilege Separation:
   - Three distinct security roles:
     - `buyer`: standard customer (browsing, cart, placing orders, accessing own quotes).
     - `seller` / `vendor`: merchant/shop owner (viewing own shop products and inventory).
     - `admin`: platform operator (system metrics, product catalog CRUD, manual order state transitions).
2. Administrative Endpoint Guards:
   - Created [services/api/app/api/v1/admin.py](file:///d:/buildmart/services/api/app/api/v1/admin.py) protected by `require_admin`.
   - When a user with role `buyer` attempts to invoke administrative endpoints (e.g. `GET /api/v1/admin/metrics` or `POST /api/v1/admin/products`), the request is rejected with HTTP 403 Forbidden.
3. Multi-Tenant Resource Ownership:
   - In [services/api/app/api/v1/orders.py](file:///d:/buildmart/services/api/app/api/v1/orders.py#L160-L185), order lookup enforces `Order.user_id == current_user.id`.
   - If Customer A attempts to view or cancel an order created by Customer B, the API returns HTTP 403 Forbidden.

---

## 3. Credential Hygiene & Secret Eradication (F-06 & F-08)

### Credential Audit & Removal
1. Ripgrep Forensic Scan:
   - Executed recursive search across all repository directories for hardcoded credentials.
   - Identified and eradicated hardcoded Cloudinary credentials (`api_secret = 'oLK_6m_...'`) across 8 legacy scripts in `scripts/audits/`, `scripts/migrations/`, and `scripts/upload/`.
   - Replaced all instances with `os.getenv('CLOUDINARY_API_KEY')` and `os.getenv('CLOUDINARY_API_SECRET')`.
2. Recommended Credential Rotation:
   - Since legacy scripts previously contained Cloudinary API secrets in historical commits, the Cloudinary API secret should be rotated immediately in the Cloudinary Console (Dashboard -> Settings -> Security -> Regenerate API Secret).
3. Firebase Client Configuration Hygiene:
   - Evaluated [mobile/android/app/google-services.json](file:///d:/buildmart/mobile/android/app/google-services.json).
   - Confirmed that this file contains only public client identifiers (`project_number`, `project_id`, `mobilesdk_app_id`, `current_key`), which are required for Android push notifications and Firebase client connection. No private service account keys or payment secrets are contained.
   - Recommended that in the Google Cloud Console, API key restrictions be configured restricting the Android key to package name `com.buildmart.app` with the production SHA-1 fingerprint.

---

## 4. Payment Security & Webhook HMAC Verification (F-01)

### Attack Vectors Prevented
1. Amount Tampering:
   - Orders cannot be placed with client-altered pricing. Subtotals are calculated server-side from active database records.
2. Premature Settlement:
   - Online orders are initialized with `payment_status="pending"` and `status="pending"`. The success screen cannot independently set an order to paid.
3. Signature Forgery:
   - Payment verification in [services/api/app/api/v1/checkout.py](file:///d:/buildmart/services/api/app/api/v1/checkout.py#L60-L80) validates `hmac.new(secret, razorpay_order_id|razorpay_payment_id, sha256)`. Invalid signatures are rejected with HTTP 400.
4. Webhook Replay Attacks:
   - `POST /api/v1/checkout/razorpay/webhook` validates raw request bytes against `x-razorpay-signature`.
   - Processed events are recorded in the `webhook_events` table; duplicate submissions return idempotent `status: "duplicate"` responses without re-executing order transitions.

---

## 5. Cloud Security Rules (F-09)

To ensure that direct client Firebase access cannot bypass the backend API, strict security rules have been authored:

1. Firestore Security Policy ([mobile/firestore.rules](file:///d:/buildmart/mobile/firestore.rules)):
   - Default deny: `match /{document=**} { allow read, write: if false; }`.
   - Profile ownership: users can read and write only their own document (`request.auth.uid == userId`).
   - Catalog read-only: products and categories are publicly readable but writable only by admins (`request.auth.token.role == 'admin'`).
   - Order write lockdown: client-side writes to `/orders/{orderId}` are strictly forbidden (`allow write: if false;`), ensuring all order creation flows through the trusted FastAPI backend.
2. Cloud Storage Policy ([mobile/storage.rules](file:///d:/buildmart/mobile/storage.rules)):
   - Default deny on all storage paths.
   - Profile uploads capped at 5MB, restricted to image MIME types.
   - Catalog assets capped at 10MB, writable only by admins.
