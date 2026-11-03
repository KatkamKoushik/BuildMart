# Deployment and Operations Guide

This document describes the container deployment topology, multi-stage Docker builds, environment variable specifications, health check monitoring, and operational runbooks for BuildMart.

Primary Source Files:
- [infra/docker-compose.yml](../../infra/docker-compose.yml)
- [services/api/Dockerfile](../../services/api/Dockerfile)
- [apps/web/Dockerfile](../../apps/web/Dockerfile)
- [services/api/requirements.lock](../../services/api/requirements.lock)
- [services/api/app/api/v1/health.py](../../services/api/app/api/v1/health.py)
- [.env.example](../../.env.example)

---

## Infrastructure Deployment Topology

The platform can be stood up locally or on containerized cloud infrastructure using Docker Compose:

```mermaid
flowchart TD
    subgraph Host["Host / Cloud Infrastructure (Ubuntu 24.04 / Docker 26+)"]
        DockerNetwork["Bridge Network (buildmart-network)"]

        subgraph Containers["Application Containers"]
            WebContainer["buildmart-web (Next.js 15 / Port 3000)"]
            ApiContainer["buildmart-api (FastAPI / Port 8000)"]
            PostgresContainer["buildmart-postgres (PostgreSQL 16 / Port 5432)"]
            RedisContainer["buildmart-redis (Redis 7 / Port 6379)"]
        end

        subgraph Volumes["Persistent Volumes"]
            PostgresData[("postgres_data volume")]
            RedisData[("redis_data volume")]
        end
    end

    WebContainer -->|Proxy /api Requests| ApiContainer
    ApiContainer -->|SQLAlchemy Connection Pool| PostgresContainer
    ApiContainer -->|Cache / Rate Limit / Revocation| RedisContainer
    PostgresContainer --> PostgresData
    RedisContainer --> RedisData
    DockerNetwork -.-> Containers
```

---

## Container Build Architecture

### 1. Web Frontend Container (`apps/web/Dockerfile`)
The Next.js 15 client is packaged using a hardened 3-stage Alpine container:
- **Stage 1 (deps)**: Installs production and build dependencies with `pnpm` using frozen lockfile verification.
- **Stage 2 (builder)**: Builds Next.js standalone server using `output: "standalone"` configured in [apps/web/next.config.ts](../../apps/web/next.config.ts).
- **Stage 3 (runner)**: Minimal runtime image running under non-root system user `nextjs:nodejs` (UID 1001) with built-in HTTP health check probe.

```bash
docker build -t buildmart-web:latest -f apps/web/Dockerfile .
```

### 2. Backend API Container (`services/api/Dockerfile`)
The FastAPI backend service is built on Debian Slim:
- **Lockfile Enforcement**: Pinned dependencies installed from [services/api/requirements.lock](../../services/api/requirements.lock).
- **Concurrency**: Executes with 4 concurrent Uvicorn workers (`--workers 4 --loop uvloop`).
- **Security**: Runs under unprivileged user `appuser` (UID 10001).

```bash
docker build -t buildmart-api:latest -f services/api/Dockerfile services/api
```

---

## Full-Stack Docker Compose Orchestration

The entire platform is orchestrated through [infra/docker-compose.yml](../../infra/docker-compose.yml):

```bash
# Start all platform containers in detached mode
docker compose -f infra/docker-compose.yml up -d

# Verify container health status
docker compose -f infra/docker-compose.yml ps
```

Services exposed:
- `buildmart-web`: Port 3000 (Next.js 15 Web Application)
- `buildmart-api`: Port 8000 (FastAPI Core Backend)
- `buildmart-postgres`: Port 5432 (PostgreSQL 16 Relational Store)
- `buildmart-redis`: Port 6379 (Redis 7 In-Memory Cache and Token Revocation)

---

## Environment Variables Configuration

All configuration is managed through environment variables loaded via Pydantic Settings in [services/api/app/core/config.py](../../services/api/app/core/config.py):

| Variable | Description | Example / Default | Production Requirement |
| :--- | :--- | :--- | :--- |
| `ENVIRONMENT` | Runtime mode (`development`, `staging`, `production`) | `production` | **Required** |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql+asyncpg://user:pass@host:5432/buildmart` | **Required** |
| `MONGODB_URI` | Firestore Enterprise MongoDB wire connection string | `mongodb://user:pass@firestore-host:27017` | Optional (if doc store used) |
| `REDIS_URL` | Redis connection string for rate limiting & token revocation | `redis://localhost:6379/0` | Optional (defaults to in-memory) |
| `SECRET_KEY` | Secret used for signing JWT authentication tokens | High-entropy 64-char string | **Required** |
| `RAZORPAY_KEY_ID` | Public gateway API key | `rzp_live_xxxxxxxx` | **Required** |
| `RAZORPAY_KEY_SECRET` | Secret gateway webhook and signature key | High-entropy secret | **Required** |
| `ALLOWED_HOSTS` | Whitelist of accepted host headers | `["api.buildmart.com"]` | **Required** |
| `CORS_ORIGINS` | Permitted cross-origin resource sharing URLs | `["https://buildmart.com"]` | **Required** |

---

## Health Check and Readiness Monitoring

The API exposes live and ready endpoints:
- Liveness Probe: `GET /api/v1/health`
- Readiness Probe: `GET /api/v1/health/ready`

```bash
curl -s http://localhost:8000/api/v1/health/ready | jq .
```

Sample JSON Response:
```json
{
  "status": "ready",
  "database": "connected",
  "redis": "connected",
  "uptime_seconds": 18420
}
```

Health check probes evaluate:
1. **Relational Database**: Issues `SELECT 1` on active connection pool.
2. **Redis In-Memory Cache**: Issues `PING` to verify cache and revocation readiness.
3. **HTTP Liveness**: Confirms ASGI event loop is processing requests normally.

---

## Monorepo Testing Suite

All tests across workspaces execute concurrently via Turborepo:

```bash
# Run unit and integration tests across all monorepo packages
npx pnpm test

# Run tests with turborepo caching
npx turbo run test

# Run backend Python tests specifically
cd services/api && pytest -v

# Run Flutter mobile tests
cd mobile && flutter test --coverage
```

Test Suites:
- `packages/shared`: Node 24 native test runner testing Zod schemas ([packages/shared/test/schemas.test.mjs](../../packages/shared/test/schemas.test.mjs)).
- `apps/web`: Node 24 native test runner testing API client contracts ([apps/web/test/api.test.mjs](../../apps/web/test/api.test.mjs)).
- `services/api`: Pytest async testing auth, orders, payments, rate limits, and security headers (48 test cases).

---

## Operational Runbooks

### 1. Database Backup (PostgreSQL)
```bash
docker exec -t buildmart-postgres pg_dumpall -c -U postgres > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 2. Restoring Database from Backup
```bash
cat backup_file.sql | docker exec -i buildmart-postgres psql -U postgres -d buildmart
```

### 3. Applying Zero-Downtime Alembic Migrations
```bash
docker exec -t buildmart-api alembic upgrade head
```

---

## Architecture Decision Records (ADRs)

Key architectural decisions are documented under `docs/adr/`:
- [ADR 0001: Dual Database Persistence Architecture](../../docs/adr/0001-dual-database-persistence.md)
- [ADR 0002: Monorepo Orchestration via pnpm Workspaces and Turborepo](../../docs/adr/0002-pnpm-turborepo-monorepo.md)
- [ADR 0003: Server-Authoritative Procurement, Statutory GST Invariants, and Payment Integrity](../../docs/adr/0003-server-authoritative-procurement.md)
