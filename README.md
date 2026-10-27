# BuildMart

Production-grade construction materials marketplace and commercial procurement platform managed as a pnpm monorepo with a Next.js 15 frontend, FastAPI Python backend, shared TypeScript library, and retained Flutter mobile application.

[![Web CI](https://github.com/KatkamKoushik/BuildMart/actions/workflows/ci-web.yml/badge.svg)](https://github.com/KatkamKoushik/BuildMart/actions/workflows/ci-web.yml)
[![API CI](https://github.com/KatkamKoushik/BuildMart/actions/workflows/ci-api.yml/badge.svg)](https://github.com/KatkamKoushik/BuildMart/actions/workflows/ci-api.yml)
[![Mobile CI](https://github.com/KatkamKoushik/BuildMart/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/KatkamKoushik/BuildMart/actions/workflows/flutter_ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/KatkamKoushik/BuildMart?color=blue&logo=github)](https://github.com/KatkamKoushik/BuildMart/releases)
[![Pytest Suite](https://img.shields.io/badge/pytest-15%20passed-success?logo=pytest&logoColor=white)](forensic-report/TEST_EXECUTION_REPORT.md)
[![Code Coverage](https://img.shields.io/badge/coverage-69%25-green?logo=pytest)](forensic-report/TEST_EXECUTION_REPORT.md)
[![Catalog Audit](https://img.shields.io/badge/catalog%20audit-210%20verified-blue)](scripts/audits/catalog_audit_report.json)
[![Next.js](https://img.shields.io/badge/Next.js-15.5-black?logo=next.js&logoColor=white)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-19.0-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![pnpm](https://img.shields.io/badge/pnpm-12.4-F69220?logo=pnpm&logoColor=white)](https://pnpm.io/)
[![Turborepo](https://img.shields.io/badge/Turborepo-2.x-EF4444?logo=turborepo&logoColor=white)](https://turbo.build/)

---

## Architecture Overview

```text
buildmart/
├── apps/
│   └── web/                   # Next.js 15 (App Router, React 19, TypeScript, Tailwind CSS)
│       ├── src/app/           # Home, Products, Product Detail, Checkout, Orders, Quotes, Shops
│       ├── src/components/    # Header, Footer, CartDrawer, HeroBanners, FeaturedProducts
│       ├── src/stores/        # Zustand client state management
│       └── src/lib/           # Typed API Client, formatters, and utilities
│
├── services/
│   └── api/                   # Python FastAPI Backend
│       ├── app/api/v1/        # Products, Categories, Brands, Shops, Cart, Orders, Checkout, Quotes
│       ├── app/models/        # SQLAlchemy 2.0 ORM Declarative Models
│       ├── app/schemas/       # Pydantic v2 Request and Response Schemas
│       ├── app/core/          # Configuration, Security, and Authentication
│       ├── app/seed.py        # Seed pipeline importing 210 products and 16 categories
│       ├── tests/             # Automated Pytest Integration Suite
│       └── Dockerfile         # Production Container Definition
│
├── packages/
│   └── shared/                # Shared TypeScript Domain Types and Zod Schemas
│       ├── src/types.ts       # Unified data models
│       └── src/schemas.ts     # Zod runtime validation
│
├── mobile/                    # Flutter Mobile Application (iOS and Android)
│   ├── lib/                   # Riverpod 2, Freezed, GoRouter, SecureStorage
│   └── test/                  # Flutter Unit and Widget Test Suite
│
├── infra/
│   └── docker-compose.yml     # PostgreSQL 16, Redis 7, and FastAPI Service
│
├── .github/workflows/
│   ├── ci-web.yml             # Next.js Typecheck and Build Pipeline
│   ├── ci-api.yml             # FastAPI Seed and Pytest Suite Pipeline
│   └── flutter_ci.yml         # Mobile Flutter Test and APK Build Pipeline
│
├── pnpm-workspace.yaml        # pnpm Workspace Package Definitions
├── turbo.json                 # Turborepo Build Cache and Task Orchestration
└── .env.example               # Unified Monorepo Environment Configuration
```

---

## Technology Stack

### Frontend (apps/web)
- Framework: Next.js 15 (App Router, React Server Components)
- Language: TypeScript 5.5+
- Styling: Tailwind CSS with tailored industrial construction palette
- State Management: Zustand (Cart, Wishlist, UI Drawers)
- Icons: Lucide React

### Backend (services/api)
- Framework: FastAPI 0.115+
- Language: Python 3.12
- ORM: SQLAlchemy 2.0 (Async Engine)
- Database: PostgreSQL 16 (with SQLite/aiosqlite local development fallback)
- Cache: Redis 7
- Serialization: Pydantic v2
- PDF Generation: ReportLab
- Payment Verification: Razorpay Python SDK (HMAC-SHA256 signature verification)
- Testing: Pytest with HTTPX AsyncClient

### Shared Library (packages/shared)
- Language: TypeScript
- Validation: Zod schemas for addresses, cart operations, checkout, and quote requests

### Mobile (mobile/)
- Framework: Flutter 3.x
- State Management: Riverpod 2 with code generation
- Navigation: GoRouter
- Storage: flutter_secure_storage for hardware keystore isolation

---

## Prerequisites

- Node.js: >= 20.0.0
- pnpm: >= 9.0.0 (`npm i -g pnpm`)
- Python: >= 3.12 with pip
- Docker: Docker Desktop or Docker Engine with Docker Compose (optional for local Postgres/Redis)

---

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/KatkamKoushik/BuildMart.git
cd buildmart
```

### 2. Configure Environment Variables
Copy the unified environment template to create your local `.env`:
```bash
cp .env.example .env
```

### 3. Install Monorepo Dependencies
Install root and workspace packages:
```bash
pnpm install
```

### 4. Setup and Seed the Backend Database
Navigate to the API service directory, install dependencies, and run the automated seed command:
```bash
cd services/api
pip install -r requirements.txt
pip install email-validator
python -m app.seed
cd ../..
```

The seed pipeline populates:
- 16 Material Categories (Cement, Steel, Bricks, Plumbing, Electricals, Tiles, Paints, etc.)
- 18 Manufacturer Brands (UltraTech, Tata Tiscon, Berger, Astral, CenturyDoors, Jaquar, etc.)
- 3 Verified Distribution Yards
- 210 Catalog Products with specifications, images, and prices
- 8 Promotional Banners
- Default Demo User account for testing

### 5. Start Development Servers
From the repository root, start both the Next.js frontend and FastAPI backend concurrently using Turborepo:
```bash
pnpm dev
```

Alternatively, run each service independently:
```bash
# Next.js Web Application (http://localhost:3000)
pnpm dev:web

# FastAPI Backend Server (http://localhost:8000 | Interactive Docs at http://localhost:8000/docs)
pnpm dev:api
```

---

## Testing and Quality Verification

### Typecheck Shared Library
```bash
pnpm --filter @buildmart/shared typecheck
```

### Typecheck and Build Next.js Application
```bash
pnpm --filter @buildmart/web typecheck
pnpm --filter @buildmart/web build
```

### Run Python API Test Suite
```bash
cd services/api
pytest -v
cd ../..
```

The automated test suite verifies:
- Service health endpoint
- Category listing and product count aggregations
- Product search, category filters, and price sorting
- Cart lifecycle (add item, update quantity, item total calculation, item removal, cart clear)
- Order placement, item snapshots, statutory tax calculation, order history, and cancellation
- Commercial Bill of Materials (BOM) quote submission and ReportLab PDF document compilation

---

## API Endpoints Reference

All endpoints are versioned under `/api/v1`:

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/health` | Service health status and environment |
| `GET` | `/categories` | List material categories with live product counts |
| `GET` | `/categories/{id}` | Retrieve specific category details |
| `GET` | `/brands` | List manufacturer brands with category filtering |
| `GET` | `/banners` | Retrieve active promotional banners |
| `GET` | `/shops` | List verified material yards and suppliers with distance |
| `GET` | `/shops/{id}` | Retrieve supplier yard details |
| `GET` | `/shops/{id}/products` | List products supplied by specific yard |
| `GET` | `/products` | Filter products by category, brand, shop, search query, price, sorting |
| `GET` | `/products/{id}` | Retrieve product details and specifications |
| `GET` | `/cart` | Retrieve current user cart with subtotal, 18% GST, and delivery fees |
| `POST` | `/cart/items` | Add product to cart |
| `PUT` | `/cart/items/{id}` | Update quantity of cart item |
| `DELETE` | `/cart/items/{id}` | Remove item from cart |
| `DELETE` | `/cart` | Clear entire cart |
| `POST` | `/checkout/razorpay/create-order` | Generate Razorpay order ID |
| `POST` | `/checkout/razorpay/verify` | Verify Razorpay payment signature via HMAC-SHA256 |
| `POST` | `/checkout/razorpay/webhook` | Process Razorpay raw-body webhooks with replay deduplication |
| `POST` | `/orders` | Place new order with site delivery address |
| `GET` | `/orders` | List user order history |
| `GET` | `/orders/{id}` | Retrieve order status and tracking timeline |
| `POST` | `/orders/{id}/cancel` | Cancel eligible pending or confirmed order |
| `PUT` | `/orders/{id}/status` | Update order lifecycle status (Admin only) |
| `POST` | `/quotes` | Submit commercial project quote request |
| `GET` | `/quotes/{id}/pdf` | Download dynamically generated branded PDF quotation |
| `POST` | `/auth/token` | Obtain signed JWT access token |
| `GET` | `/auth/me` | Retrieve active user profile |
| `POST` | `/auth/address` | Add delivery address to user account |
| `GET` | `/admin/metrics` | Retrieve platform KPI summary and sales metrics (Admin only) |
| `GET` | `/admin/orders` | List all platform orders across all users (Admin only) |
| `POST/PUT/DELETE` | `/admin/products` | Manage product catalog entries (Admin only) |

---

## Infrastructure and Production Deployment

### Docker Compose
Start PostgreSQL 16 and Redis 7:
```bash
docker compose -f infra/docker-compose.yml up -d
```

### Continuous Integration (GitHub Actions)
The repository includes automated CI workflows:
- `ci-web.yml`: Validates `@buildmart/shared` and `@buildmart/web` type safety and production build.
- `ci-api.yml`: Sets up Python 3.12, executes data seeder, and runs full pytest suite.
- `flutter_ci.yml`: Runs Dart static analysis, formatting checks, widget test suite, and debug APK build.

---

## Security Policies

- Secret Isolation: Secrets must reside exclusively in `.env` or CI secret vaults. Privileged keys (such as `RAZORPAY_KEY_SECRET` or database master passwords) are never bundled into client applications.
- Input Validation: All network payloads are validated using Pydantic v2 on the backend and Zod on the frontend.
- Statutory Compliance: Invoices include 18% GST construction tax calculations with Input Tax Credit eligibility.

---

## About BuildMart

BuildMart is a digital procurement and supply chain infrastructure platform purpose-built for the building construction industry. By bridging the gap between primary manufacturers (such as UltraTech, Tata Tiscon, Ambuja, and Berger) and certified regional material yards, BuildMart enables contractors, infrastructure developers, and builders to procure high-specification materials at transparent factory-direct prices.

### Core Value Propositions
- Direct Mill Sourcing: Complete authenticity with manufacturer Mill Test Certificates (MTC) and Bureau of Indian Standards (BIS) conformity.
- Automated Commercial Estimating: Contractors can generate instant PDF quotations for Bill of Materials (BOM) client approval.
- Tax and Accounting Ready: Guaranteed 18% GST e-invoices with full Input Tax Credit (ITC) eligibility.
- Logistics Transparency: Real-time fleet tracking from regional distribution hubs to project site gates.

---

## Releases and Changelog

Official release packages, tags, and changelogs are tracked on GitHub Releases:

- [Release v2.0.0](https://github.com/KatkamKoushik/BuildMart/releases/tag/v2.0.0) (Latest)
  - Full-stack monorepo transformation with pnpm and Turborepo.
  - Next.js 15 App Router web application replacing legacy Flutter Web.
  - Asynchronous FastAPI Python backend with SQLAlchemy 2.0 ORM.
  - Automated database seed pipeline importing 16 material categories, 18 brands, and 210 products.
  - Dynamic ReportLab PDF commercial quotation generator.
  - Comprehensive automated Pytest and Next.js build CI pipelines.

