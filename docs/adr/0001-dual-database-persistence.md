# ADR 0001: Dual Database Persistence Architecture

## Status
Accepted

## Date
2026-11-03

## Context
BuildMart operates as a high-concurrency B2B and B2C marketplace for construction materials, equipment rentals, and turnkey contracting. The platform must satisfy two distinct data storage and access requirements:

1. **Relational Procurement Ledger (ACID Guarantees)**:
   Order lifecycle management, inventory decrements, statutory 18% GST tax computations, payment settlement states, and relational customer-supplier graphs require strict referential integrity, multi-table transactions, and deterministic serialization.

2. **Document-Oriented Product Catalog & Search**:
   Construction material catalogs feature deeply nested hierarchical attributes (such as compressive strength for cement, tensile yield for TMT steel rebars, batch certifications, and varying vendor specifications). These require flexible, schema-less document indexing, fast read performance, and full-text keyword filtering.

## Decision
We adopt a hybrid dual-database architecture:
1. **Primary Relational Store**: PostgreSQL 16 managed via SQLAlchemy 2.0 with asyncpg driver and Alembic schema migrations. This store is the authoritative source of truth for:
   - Users and credentials (`users`)
   - Product catalog definitions and prices (`products`)
   - Procurement orders and line items (`orders`, `order_items`)
   - Payments and transaction states (`payments`)
   - Inventory reservation ledgers

2. **Secondary Document Store**: Google Cloud Firestore utilizing the MongoDB wire protocol compatibility layer via PyMongo and Motor. This store is utilized for:
   - Dynamic product attribute extensions and certification metadata
   - High-throughput read-heavy search indices
   - Offline-first cache syncing with mobile clients

## Invariants and Guardrails
- **Single Source of Truth**: The PostgreSQL database remains the sole authoritative record for pricing, order states, and user entitlements. Under no circumstances may client-side applications or secondary stores mutate financial balances or inventory without an underlying PostgreSQL transaction.
- **Transactional Consistency**: Order placement utilizes atomic database transactions. If an inventory decrement or payment record fails to persist, the entire transaction rolls back cleanly.
- **Fail-Open Secondary Reads**: If the secondary document store experiences transient downtime, the API falls back transparently to PostgreSQL relational queries.

## Alternatives Considered
- **Single Monolithic PostgreSQL Store**: While PostgreSQL supports JSONB columns, querying deeply nested polymorphic attributes across hundreds of thousands of material variants introduces index bloat and query contention with high-velocity procurement transactions.
- **Pure NoSQL (MongoDB / DynamoDB Only)**: Lacks ACID transactional guarantees across multi-vendor order splittings, foreign key constraints, and standard SQL auditing required for statutory Indian GST accounting compliance.

## Consequences
- **Positive**:
  - Uncompromised financial integrity for orders, payments, and inventory.
  - Sub-millisecond read access for rich, polymorphic product catalogs.
  - Decoupled scalability: read-heavy product browsing does not lock relational order tables.
- **Negative**:
  - Requires maintaining two database client connection pools and health checks in the backend service.
  - Requires automated data synchronization pipelines between PostgreSQL and Firestore for catalog updates.

## References
- Architectural Topology: [Architecture.md](../wiki/Architecture.md)
- Relational Schema and Migrations: [Database-and-Persistence.md](../wiki/Database-and-Persistence.md)
- SQLAlchemy Models: [services/api/app/models/](../../services/api/app/models/)
