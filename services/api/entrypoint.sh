#!/bin/sh
set -e

# Automatically apply database schema migrations via Alembic before starting the server
if [ -n "$DATABASE_URL" ]; then
    echo "Applying database schema migrations via Alembic..."
    alembic upgrade head || {
        echo "Alembic migration failed"
        exit 1
    }
fi

exec "$@"
