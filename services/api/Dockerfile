# ==============================================================================
# BuildMart API Multi-Stage Production Container
# Hardened non-root runtime with minimal attack surface
# ==============================================================================

# Stage 1: Build Dependencies
FROM python:3.12-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.lock requirements.txt ./
RUN pip wheel --no-cache-dir --wheel-dir=/wheels -r requirements.lock

# Stage 2: Hardened Runtime
FROM python:3.12-slim AS runtime

WORKDIR /app

# Install only curl for healthcheck execution
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install pre-built wheels from builder stage
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels /wheels/* \
    && rm -rf /wheels

# Create unprivileged non-root user and group
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /sbin/nologin -d /app appuser

# Copy application source and set ownership
COPY --chown=appuser:appgroup . .

# Ensure entrypoint is executable
RUN chmod +x /app/entrypoint.sh

# Switch to unprivileged non-root user
USER appuser:appgroup

# Expose API port
EXPOSE 8000

# Container Healthcheck verifying readiness probe
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health/ready || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]

# Start production uvicorn worker
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
