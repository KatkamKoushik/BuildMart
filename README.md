# BuildMart 🏗️

> **Production-Grade Construction Materials Marketplace & Commercial Procurement Platform**  
> Managed as a high-performance **pnpm monorepo** with a **Next.js 15** frontend, **FastAPI** Python backend, and retained **Flutter** mobile client.

---

## 🏛️ Monorepo Architecture

```text
buildmart/
├── apps/
│   └── web/                   # Next.js 15 (App Router, React 19, TypeScript, Tailwind CSS)
│       ├── src/app/           # Home, Products, Checkout, Orders, Quotes, Shops
│       ├── src/components/    # Header, Footer, CartDrawer, HeroBanners, FeaturedProducts
│       ├── src/stores/        # Zustand reactive state stores
│       └── src/lib/           # Typed API Client & UI Utilities
│
├── services/
│   └── api/                   # Python FastAPI Backend
│       ├── app/api/v1/        # Products, Categories, Brands, Shops, Cart, Orders, Checkout, Quotes
│       ├── app/models/        # SQLAlchemy 2.0 ORM Declarative Models
│       ├── app/schemas/       # Pydantic v2 Request/Response Schemas
│       ├── app/core/          # Configuration, Security, and Auth
│       ├── app/seed.py        # Seed pipeline importing 210 products & 16 categories
│       ├── tests/             # Automated Pytest Integration Suite
│       └── Dockerfile         # Production Container Definition
│
├── packages/
│   └── shared/                # Shared TypeScript Domain Types & Zod Schemas
│
├── mobile/                    # Flutter Mobile Application (iOS & Android)
│   ├── lib/                   # Riverpod 2, Freezed, GoRouter, SecureStorage
│   └── test/                  # Flutter Unit & Widget Test Suite
│
├── infra/
│   └── docker-compose.yml     # PostgreSQL 16, Redis 7, and FastAPI Service
│
├── .github/workflows/
│   ├── ci-web.yml             # Next.js Typecheck & Build Pipeline
│   ├── ci-api.yml             # FastAPI Pytest & Seed Pipeline
│   └── flutter_ci.yml         # Mobile Flutter Test & APK Build Pipeline
│
├── pnpm-workspace.yaml        # pnpm Monorepo Workspace Definitions
├── turbo.json                 # Turborepo Build Cache & Task Orchestration
└── .env.example               # Unified Monorepo Environment Configuration
```

---

## 🚀 Quick Start Guide

### Prerequisites
- **Node.js**: >= 20.0.0
- **pnpm**: >= 9.0.0 (`npm i -g pnpm`)
- **Python**: >= 3.12 with pip
- **Docker** (optional for Postgres/Redis): `docker compose`

### 1. Setup Environment
```bash
# Clone the repository
git clone https://github.com/KatkamKoushik/BuildMart.git
cd buildmart

# Copy safe local environment template
cp .env.example .env
```

### 2. Install Monorepo Dependencies
```bash
pnpm install
```

### 3. Initialize & Seed Python Backend
```bash
cd services/api
pip install -r requirements.txt
python -m app.seed
```

### 4. Run Development Servers
From the repository root:
```bash
# Run both Frontend & Backend concurrently via Turborepo:
pnpm dev

# Or run individual services:
pnpm dev:web     # Next.js Web App at http://localhost:3000
pnpm dev:api     # FastAPI Backend at http://localhost:8000 (Docs at /docs)
```

---

## 🧪 Testing & Validation

```bash
# Shared Package Typecheck
pnpm --filter @buildmart/shared typecheck

# Next.js Web App Typecheck & Build
pnpm --filter @buildmart/web typecheck
pnpm --filter @buildmart/web build

# Python Backend Pytest Suite
cd services/api
pytest -v
```

---

## 🔒 Security & Quality Highlights

- **Direct Factory Sourcing:** Mill Test Certificates (MTC) and BIS compliance verification.
- **GST Invoicing:** 18% statutory construction tax computation with Input Tax Credit (ITC) tracking.
- **Dynamic Project Quotations:** Instant server-side PDF generation for commercial contractor procurement.
- **Token Security:** Hardware Keystore token encryption on mobile, secure HTTP-only cookies on web.
- **Payment Gateway:** Razorpay SDK integration with server-side HMAC-SHA256 signature verification.
