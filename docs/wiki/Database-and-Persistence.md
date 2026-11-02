# Database and Persistence Architecture

This document describes the dual-database persistence tier of BuildMart, including the primary relational schema (PostgreSQL 16), migration workflows (Alembic), and document store integration (Google Cloud Firestore Enterprise MongoDB Wire Protocol).

Primary Source Files:
- [services/api/app/models/models.py](file:///d:/buildmart/services/api/app/models/models.py)
- [services/api/app/db/session.py](file:///d:/buildmart/services/api/app/db/session.py)
- [services/api/app/db/mongodb.py](file:///d:/buildmart/services/api/app/db/mongodb.py)
- [services/api/app/seed.py](file:///d:/buildmart/services/api/app/seed.py)
- [services/api/alembic](file:///d:/buildmart/services/api/alembic)

---

## Dual-Database Topology

BuildMart adopts a hybrid persistence strategy:

```mermaid
flowchart TD
    subgraph AppService["FastAPI Application Core"]
        SQLAlchemyEngine["SQLAlchemy 2.0 AsyncIO Engine<br/>(Connection Pool: 20-50)"]
        PyMongoClient["PyMongo Thread-Safe Client<br/>(Pool Size: 5-50)"]
    end

    subgraph RelationalDB["Relational Tier (ACID Invariants)"]
        PostgresPrimary[("PostgreSQL 16 Engine<br/>- Users & Authentication<br/>- Categories & Products<br/>- Cart Items & Orders<br/>- Order Items & Ledger<br/>- Razorpay Webhooks Audit")]
    end

    subgraph DocumentDB["Document Tier (Flexible Metadata)"]
        FirestoreWire[("Firestore Enterprise MongoDB Wire<br/>- Unstructured Product Specs<br/>- IoT Telemetry & Dispatch Geofencing<br/>- Material Mill Test Certificates (MTC)")]
    end

    SQLAlchemyEngine -->|Async Session / Transactions| PostgresPrimary
    PyMongoClient -->|Wire Protocol / Ping Health| FirestoreWire
```

---

## Relational Entity-Relationship Diagram

The relational schema strictly enforces foreign key integrity, cascade deletions, and index optimization across all procurement entities:

```mermaid
erDiagram
    users ||--o{ orders : places
    users ||--o{ cart_items : owns
    shops ||--o{ products : supplies
    categories ||--o{ products : classifies
    categories ||--o{ brands : includes
    brands ||--o{ products : manufactures
    orders ||--|{ order_items : contains
    products ||--o{ order_items : references
    products ||--o{ cart_items : references

    users {
        string id PK "UUIDv4"
        string firebase_uid UK "Optional External Auth UID"
        string name "Full Name"
        string email UK "Indexed Unique Email"
        string phone "Contact Number"
        string hashed_password "Argon2 / Bcrypt Hash"
        string role "buyer | vendor | admin"
        json saved_addresses "Serialized Address List"
        datetime created_at "UTC Timestamp"
    }

    shops {
        string id PK "UUIDv4"
        string name "Material Yard Name"
        string address "Yard Physical Location"
        float latitude "GPS Coordinate"
        float longitude "GPS Coordinate"
        float distance_km "Proximity Index"
        boolean is_open "Operational Status"
        json categories "Supported Category Tags"
    }

    categories {
        string id PK "Slug ID (e.g., cement, steel)"
        string name "Display Category Name"
        string image_url "CDN Asset Path"
        int sort_order "Display Priority"
    }

    brands {
        string id PK "Brand Slug ID"
        string name "Manufacturer Name"
        string category_id FK "Owning Category"
        string image_url "Logo CDN URL"
    }

    products {
        string id PK "UUIDv4"
        string title "Product Title"
        text description "Detailed Specifications"
        float price "Server-Authoritative Price"
        float original_price "MSRP Reference"
        string category_id FK "Owning Category"
        string shop_id FK "Supplying Yard"
        string brand_id FK "Manufacturer Brand"
        json image_urls "Gallery Image URLs"
        json specifications "Technical Specifications"
        int stock_quantity "Available Inventory"
        string unit "bag | ton | piece | sqft"
        boolean is_active "Live Status"
    }

    cart_items {
        string id PK "UUIDv4"
        string user_id FK "Owner User"
        string product_id FK "Target Product"
        int quantity "Selected Quantity"
    }

    orders {
        string id PK "UUIDv4"
        string order_number UK "Indexed Order Identifier"
        string user_id FK "Customer ID"
        float subtotal "Pre-tax Order Value"
        float tax "Statutory 18% GST"
        float delivery_fee "Logistics Surcharge"
        float total_amount "Total Payable Amount"
        string status "pending | confirmed | dispatched | delivered | cancelled"
        string payment_method "razorpay | cod | upi"
        string payment_status "pending | paid | failed"
        string razorpay_order_id "Gateway Order ID"
        string razorpay_payment_id "Gateway Transaction ID"
        string idempotency_key UK "Client Request Deduplicator"
        json delivery_address "Site Delivery Address"
    }

    order_items {
        string id PK "UUIDv4"
        string order_id FK "Parent Order"
        string product_id FK "Referenced Product"
        string title "Historical Title Snapshot"
        float price "Historical Price Snapshot"
        int quantity "Purchased Quantity"
        string unit "Unit of Measurement"
    }

    quote_requests {
        string id PK "UUIDv4"
        string quote_number UK "Indexed Quote Identifier"
        string customer_name "Client Contact Name"
        string email "Client Email"
        string delivery_pincode "Site Postal Code"
        json items "BOM Items List"
        float estimated_total "Calculated Estimate"
        string status "submitted | approved | rejected"
    }

    webhook_events {
        string id PK "UUIDv4"
        string event_id UK "Razorpay Unique Event ID"
        string event_type "payment.captured | order.paid"
        json payload "Raw Webhook Body"
        string status "processed | ignored | failed"
        datetime processed_at "Audit Timestamp"
    }
```

---

## Migration Management with Alembic

Database schema evolutions are versioned and executed through Alembic.

### Running Migrations
To apply all pending revisions to head:
```bash
cd services/api
alembic upgrade head
```

### Creating Revisions
```bash
alembic revision --autogenerate -m "describe_schema_change"
```

### Migration Automated Verification
The repository contains an automated test [services/api/tests/test_migrations.py](file:///d:/buildmart/services/api/tests/test_migrations.py) that verifies migration upgrade and rollback integrity during CI builds.

---

## Firestore Enterprise MongoDB Wire Protocol Integration

For document storage, audit logging, and flexible specifications, BuildMart integrates with Google Cloud Firestore's MongoDB compatibility wire protocol using PyMongo:

Source implementation: [services/api/app/db/mongodb.py](file:///d:/buildmart/services/api/app/db/mongodb.py)

Key configurations:
- `serverSelectionTimeoutMS`: 5,000 ms
- `connectTimeoutMS`: 5,000 ms
- `socketTimeoutMS`: 10,000 ms
- `maxPoolSize`: 50 connections
- `minPoolSize`: 5 connections

Health verification is exposed on `/api/v1/health` where `ping` commands verify active connectivity to the document store.

---

## Database Seeding Pipeline

Source: [services/api/app/seed.py](file:///d:/buildmart/services/api/app/seed.py)

During local development and automated testing, the seeding pipeline executes automatically on application lifespan startup:
- **16 Material Categories**: Cement, Steel, Bricks, Plumbing, Electricals, Tiles, Paints, Hardware, Sanitaryware, etc.
- **18 Primary Brands**: UltraTech, Tata Tiscon, Ambuja, Berger, Astral, Jaquar, CenturyDoors, etc.
- **3 Verified Distribution Yards**: Regional yards with physical addresses and geo-coordinates.
- **210 Catalog Products**: Detailed product profiles with technical specifications and pricing.
- **8 Promotional Banners**: Commercial banners featuring active discounts and material highlights.
- **Default Seed User**: Demo account initialized with pre-populated delivery addresses.

In production environments (`ENVIRONMENT=production`), automatic seeding is disabled to prevent database mutation.
