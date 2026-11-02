# Deployment and Operations Guide

This document describes the container deployment topology, environment variable specifications, health check monitoring, and operational runbooks for BuildMart.

Primary Source Files:
- [infra/docker-compose.yml](file:///d:/buildmart/infra/docker-compose.yml)
- [services/api/Dockerfile](file:///d:/buildmart/services/api/Dockerfile)
- [services/api/app/api/v1/health.py](file:///d:/buildmart/services/api/app/api/v1/health.py)
- [.env.example](file:///d:/buildmart/.env.example)

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
    ApiContainer -->|Cache / Rate Limit| RedisContainer
    PostgresContainer --> PostgresData
    RedisContainer --> RedisData
    DockerNetwork -.-> Containers
```

---

## Environment Variables Configuration

All configuration is managed through environment variables loaded via Pydantic Settings in [services/api/app/core/config.py](file:///d:/buildmart/services/api/app/core/config.py):

| Variable | Description | Example / Default | Production Requirement |
| :--- | :--- | :--- | :--- |
| `ENVIRONMENT` | Runtime mode (`development`, `staging`, `production`) | `production` | **Required** |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql+asyncpg://user:pass@host:5432/buildmart` | **Required** |
| `MONGODB_URI` | Firestore Enterprise MongoDB wire connection string | `mongodb://user:pass@firestore-host:27017` | Optional (if doc store used) |
| `REDIS_URL` | Redis in-memory cache connection string | `redis://localhost:6379/0` | Optional (defaults to in-memory) |
| `SECRET_KEY` | Secret used for signing JWT authentication tokens | High-entropy 64-char string | **Required** |
| `RAZORPAY_KEY_ID` | Public gateway API key | `rzp_live_xxxxxxxx` | **Required** |
| `RAZORPAY_KEY_SECRET` | Secret gateway webhook and signature key | High-entropy secret | **Required** |
| `ALLOWED_HOSTS` | Whitelist of accepted host headers | `["api.buildmart.com"]` | **Required** |
| `CORS_ORIGINS` | Permitted cross-origin resource sharing URLs | `["https://buildmart.com"]` | **Required** |

---

## Health Check and Readiness Monitoring

The API exposes a comprehensive health endpoint at `/api/v1/health`:

```bash
curl -s http://localhost:8000/api/v1/health | jq .
```

Sample JSON Response:
```json
{
  "status": "healthy",
  "version": "2.0.0",
  "environment": "production",
  "database": {
    "status": "connected",
    "engine": "postgresql"
  },
  "mongodb": {
    "status": "connected"
  },
  "uptime_seconds": 18420
}
```

Health check probes evaluate:
1. **Relational Database**: Issues `SELECT 1` on active connection pool.
2. **Document Database**: Dispatches `ping` command via PyMongo client.
3. **HTTP Readiness**: Confirms ASGI event loop is processing requests normally.

---

## Logging, Tracing, and Correlation

- **Correlation Tracing**: Every inbound request is assigned an `X-Request-ID`. This identifier is logged across all operational events and returned to clients in response headers.
- **Structured Output**: Log events emit timestamps, severity levels, caller correlation IDs, and execution durations.
- **Log Archiving**: In containerized environments, stdout/stderr streams are aggregated into centralized log storage (e.g., Datadog, CloudWatch, or ELK).

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
