# BuildMart

Production-grade construction materials marketplace and commercial procurement platform managed as a pnpm monorepo with a Next.js 15 frontend, FastAPI Python backend, shared TypeScript library, and retained Flutter mobile application.

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
| `POST` | `/orders` | Place new order with site delivery address |
| `GET` | `/orders` | List user order history |
| `GET` | `/orders/{id}` | Retrieve order status and tracking timeline |
| `POST` | `/orders/{id}/cancel` | Cancel eligible pending or confirmed order |
| `POST` | `/quotes` | Submit commercial project quote request |
| `GET` | `/quotes/{id}/pdf` | Download dynamically generated branded PDF quotation |
| `GET` | `/auth/me` | Retrieve active user profile |
| `POST` | `/auth/address` | Add delivery address to user account |

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
