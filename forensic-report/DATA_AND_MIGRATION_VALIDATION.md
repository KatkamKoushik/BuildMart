# BuildMart Data & Migration Validation Report

This report presents the database schema architecture, seed data pipeline validation, and catalog data integrity audit results for BuildMart.

---

## 1. Database Schema Architecture (SQLAlchemy 2.0 Async)

The relational schema is defined using SQLAlchemy 2.0 async declarative models in [services/api/app/models/models.py](file:///d:/buildmart/services/api/app/models/models.py) and is fully compatible with PostgreSQL 16 (production) and SQLite/aiosqlite (local development and automated test isolation):

### Core Entities & Relationships
1. `User` (`users`):
   - Primary key: UUID (string, 36 chars).
   - Fields: `name`, `email` (unique index), `phone`, `role` (`buyer`, `seller`, `admin`), `saved_addresses` (JSON array), `created_at`, `updated_at`.
   - Relationships: One-to-many with `Order` and `CartItem` (cascade delete).
2. `Category` (`categories`):
   - Primary key: String ID (e.g. `cement`, `steel`, `paints`, `bricks`).
   - Fields: `name`, `image_url`, `sort_order`.
   - Relationships: One-to-many with `Product` and `Brand`.
3. `Brand` (`brands`):
   - Primary key: String ID (e.g. `ultratech`, `tata_steel`, `asian_paints`).
   - Foreign key: `category_id` references `categories.id` (SET NULL on delete).
4. `Shop` (`shops`):
   - Primary key: UUID string.
   - Fields: `name`, `address`, `latitude`, `longitude`, `distance_km`, `is_open`, `rating`, `review_count`, `categories` (JSON array).
5. `Product` (`products`):
   - Primary key: UUID string.
   - Foreign keys: `category_id` (CASCADE), `brand_id` (SET NULL), `shop_id` (SET NULL).
   - Fields: `title`, `description`, `price`, `original_price`, `stock_quantity`, `unit`, `is_active`, `image_urls` (JSON array), `specifications` (JSON object).
6. `CartItem` (`cart_items`):
   - Foreign keys: `user_id` (CASCADE), `product_id` (CASCADE).
   - Quantity: Integer.
7. `Order` (`orders`):
   - Primary key: UUID string.
   - Unique identifier: `order_number` (unique index, format `BM-<timestamp>`).
   - Financial fields: `subtotal`, `tax` (18% GST), `delivery_fee`, `total_amount`.
   - Status: `status` (`pending`, `confirmed`, `processing`, `dispatched`, `delivered`, `cancelled`).
   - Payment fields: `payment_method`, `payment_status`, `razorpay_order_id`, `razorpay_payment_id`, `razorpay_signature`, `idempotency_key`.
8. `OrderItem` (`order_items`):
   - Foreign keys: `order_id` (CASCADE), `product_id` (SET NULL).
   - Fields: `title`, `price`, `quantity`, `unit`, `image_url`.
9. `WebhookEvent` (`webhook_events`):
   - Primary key: UUID string.
   - Unique identifier: `event_id` (unique index).
   - Fields: `event_type`, `payload` (JSON), `status`, `processed_at`.

---

## 2. Seed Data Pipeline & Idempotency (F-12)

The automated seeder in [services/api/app/seed.py](file:///d:/buildmart/services/api/app/seed.py) runs on application startup:

1. Schema Initialization:
   - Invokes `Base.metadata.create_all` ensuring all tables, indices, and constraints are established.
2. User Provisioning:
   - Idempotently creates default accounts:
     - Buyer: `buyer@buildmart.dev` (Role: `buyer`)
     - Administrator: `admin@buildmart.dev` (Role: `admin`)
     - Merchant/Seller: `seller@buildmart.dev` (Role: `seller`)
3. Catalog Import:
   - Ingests [mobile/assets/seeded_data.json](file:///d:/buildmart/mobile/assets/seeded_data.json).
   - Performs duplicate-checking on primary keys prior to insertion:
     - 16 Categories (cement, steel, bricks, sand, paints, plumbing, electricals, etc.)
     - 18 Brands (UltraTech, Tata Steel, Asian Paints, ACC, Jindal Panther, etc.)
     - 6 Supplier Shops (Sri Lakshmi Steels, Hyderabad Building Supplies, etc.)
     - 210 Products with specifications, images, and prices.
     - 5 Promotional Banners.
4. Idempotency Guarantee:
   - Rerunning the seed script against an existing database detects existing records and does not create duplicate entries or alter existing primary keys.

---

## 3. Catalog Integrity Audit Execution (F-12)

Executed automated audit script: [scripts/audits/catalog_integrity_audit.py](file:///d:/buildmart/scripts/audits/catalog_integrity_audit.py).

### Audit Results Summary
```json
{
  "summary": {
    "total_categories": 16,
    "total_brands": 18,
    "total_products": 210,
    "total_shops": 6,
    "total_banners": 5
  },
  "integrity_checks": {
    "duplicate_product_ids": [],
    "missing_titles": [],
    "invalid_prices": [],
    "invalid_stock": [],
    "broken_category_fks": [],
    "broken_brand_fks": [],
    "missing_or_invalid_images": []
  },
  "warnings": [],
  "passed": true
}
```

Audit Output:
- Duplicate Product IDs: 0 issues detected.
- Missing or Truncated Product Titles: 0 issues detected.
- Non-Positive or Invalid Prices: 0 issues detected.
- Broken Category Foreign Keys: 0 issues detected (all 210 products reference valid categories).
- Broken Brand Foreign Keys: 0 issues detected.
- Missing Image URLs: 0 issues detected.
- Audit Exit Code: 0 (VERIFIED PASSED).
- Machine-readable artifact: [scripts/audits/catalog_audit_report.json](file:///d:/buildmart/scripts/audits/catalog_audit_report.json).
