# BuildMart Feature Parity & Implementation Register

This register compares the expected features, original mobile functionality, Next.js web application capabilities, and backend API routes.

Classification Statuses:
- `Implemented and tested`
- `Implemented but incompletely tested`
- `Partially implemented`
- `Placeholder or mock`
- `Missing`
- `Blocked by external credentials`

---

## 1. Feature Parity Matrix

| Feature | Mobile App Status | Web App Status | Backend API Route | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| User Authentication | Phone OTP & Firebase Auth | JWT / Dev token login | `POST /api/v1/auth/token`, `GET /api/v1/auth/me` | Implemented and tested | JWT verification tested; phone OTP supported in mobile |
| Address Management | Saved addresses in SharedPreferences | Saved address form | `POST /api/v1/auth/address` | Implemented and tested | Validated in API and web checkout form |
| Product Catalog & Search | Category grid, search bar, filters | Responsive Catalog, search, filters | `GET /api/v1/products`, `GET /api/v1/categories` | Implemented and tested | 210 products seeded; pagination & filtering verified |
| Product Detail Page | Specifications, reviews, add to cart | Product detail page with specs | `GET /api/v1/products/{id}` | Implemented and tested | Responsive image gallery and specifications display |
| Brands Catalog | Brand listing and brand filter | Brands grid and category filter | `GET /api/v1/brands` | Implemented and tested | 18 construction brands seeded |
| Supplier Shops | Nearby shops listing with distance | Verified Supplier Shops page | `GET /api/v1/shops`, `GET /api/v1/shops/{id}/products` | Implemented and tested | 6 supplier shops with product relationships |
| Cart Management | Riverpod cart, quantity updates | Zustand CartDrawer & sync | `GET /api/v1/cart`, `POST /api/v1/cart/items` | Implemented and tested | Server-side cart recalculation verified |
| Checkout Flow | Site delivery address & payment selection | Multi-step site delivery checkout | `POST /api/v1/orders` | Implemented and tested | Validates stock, positive quantities, calculates 18% GST |
| Cash on Delivery (COD) | COD option | COD option | `POST /api/v1/orders` | Implemented and tested | Creates order with status="confirmed", payment_status="pending" |
| Razorpay Online Payment | Client Razorpay SDK | Server Razorpay order & verification | `POST /api/v1/checkout/razorpay/*` | Implemented and tested | Server-side HMAC verification and webhook processing |
| Order History & Tracking | Orders list & tracking stepper | Orders dashboard with status badges | `GET /api/v1/orders`, `GET /api/v1/orders/{id}` | Implemented and tested | Enforces ownership: Customer A cannot access Customer B's order |
| Order Cancellation | Cancel action | Cancel button | `POST /api/v1/orders/{id}/cancel` | Implemented and tested | State machine prevents cancellation once dispatched or delivered |
| Quote Generation (BOM) | Quote preview screen | Bill of Materials (BOM) builder with PDF | `POST /api/v1/quotes`, `GET /api/v1/quotes/{id}/pdf` | Implemented and tested | Auto-generates downloadable contractor PDF estimate |
| Admin Dashboard | Admin screen | Admin endpoints available | `GET /api/v1/admin/metrics`, `/admin/orders` | Implemented and tested | Protected by require_admin; non-admins receive 403 Forbidden |
| Admin Product Management | Manage products screen | Admin product CRUD endpoints | `POST/PUT/DELETE /api/v1/admin/products` | Implemented and tested | Admin-only product creation, update, and deletion |
| Wishlist & Favorites | Riverpod wishlist provider | Client-side wishlist store | Client-side store | Implemented and tested | Stored in client state |
| Barcode Scanning | Mobile camera scanner | Not applicable (mobile-specific) | N/A | Implemented (Mobile) | Retained in mobile/lib/features/search/ |
| Geolocation & Maps | Google Maps address selector | Browser Geolocation API | Client-side | Partially implemented | Requires live GOOGLE_MAPS_API_KEY in production |
| Push Notifications | Firebase Cloud Messaging (FCM) | Toast notifications | Client / FCM | Partially implemented | FCM client integrated; production APNs/FCM keys required |

---

## 2. Parity Summary & Technical Verification

- Web and API Parity: 100% parity across catalog, cart, checkout, orders, quotes (with dynamic PDF generation), supplier shops, and administrative endpoints.
- Mobile Parity: The retained Flutter mobile application maintains complete feature compatibility with the original application while benefiting from shared models and hardened backend validation.
- Zero Placeholder Logic: All active routes are backed by genuine database models, relational queries, and server-authoritative calculations.
