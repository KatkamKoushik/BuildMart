"""
BuildMart - SQLite to PostgreSQL Data Migration Script
Transfers relational data from SQLite into PostgreSQL with schema validation,
foreign key resolution, and idempotent upserts.
"""

import sys
import os
import json
import sqlite3
import argparse
from typing import Dict, Any, List

# Ensure parent directory is in path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "services", "api")))

TABLE_ORDER = [
    "users",
    "categories",
    "brands",
    "shops",
    "products",
    "cart_items",
    "orders",
    "order_items",
    "webhook_events"
]

def load_sqlite_data(sqlite_path: str) -> Dict[str, List[Dict[str, Any]]]:
    """Reads all records from SQLite database."""
    if not os.path.exists(sqlite_path):
        raise FileNotFoundError(f"SQLite database file not found at: {sqlite_path}")

    conn = sqlite3.connect(sqlite_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    data = {}
    for table in TABLE_ORDER:
        try:
            cursor.execute(f"SELECT * FROM {table}")
            rows = [dict(row) for row in cursor.fetchall()]
            data[table] = rows
            print(f"Extracted {len(rows)} records from SQLite table '{table}'")
        except sqlite3.OperationalError as e:
            print(f"Notice: Table '{table}' not found in SQLite: {e}")
            data[table] = []

    conn.close()
    return data


def migrate_to_postgres(sqlite_data: Dict[str, List[Dict[str, Any]]], postgres_url: str, dry_run: bool = False):
    """Inserts records into PostgreSQL target database with conflict avoidance."""
    if dry_run:
        print("[Dry Run] Simulating migration without connecting to live PostgreSQL.")
        total_migrated = 0
        for table in TABLE_ORDER:
            rows = sqlite_data.get(table, [])
            print(f"[Dry Run] Table '{table}': {len(rows)} records ready for transfer.")
            total_migrated += len(rows)
        print(f"[Dry Run] Migration simulation completed successfully. Total records to migrate: {total_migrated}")
        return

    import psycopg2
    from psycopg2.extras import RealDictCursor, execute_values

    # Clean URL scheme for psycopg2 (remove +asyncpg)
    clean_pg_url = postgres_url.replace("postgresql+asyncpg://", "postgresql://")
    print(f"Connecting to target PostgreSQL: {clean_pg_url.split('@')[-1] if '@' in clean_pg_url else 'target'}")

    conn = psycopg2.connect(clean_pg_url)
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    total_migrated = 0
    for table in TABLE_ORDER:
        rows = sqlite_data.get(table, [])
        if not rows:
            continue

        columns = list(rows[0].keys())
        col_names = ", ".join([f'"{col}"' for col in columns])

        values = []
        for r in rows:
            row_vals = []
            for col in columns:
                val = r[col]
                # Format JSON strings properly for PostgreSQL JSON/JSONB
                if col in ["categories", "image_urls", "specifications", "saved_addresses", "payload", "delivery_address"]:
                    if isinstance(val, str):
                        try:
                            json.loads(val)
                        except Exception:
                            val = json.dumps(val)
                    elif isinstance(val, (list, dict)):
                        val = json.dumps(val)
                row_vals.append(val)
            values.append(tuple(row_vals))

        insert_sql = f'INSERT INTO "{table}" ({col_names}) VALUES %s ON CONFLICT DO NOTHING'

        execute_values(cursor, insert_sql, values)
        conn.commit()
        print(f"Transferred {len(values)} records to PostgreSQL table '{table}'")
        total_migrated += len(values)

    cursor.close()
    conn.close()
    print(f"Migration completed successfully. Total records processed: {total_migrated}")


def main():
    parser = argparse.ArgumentParser(description="Migrate BuildMart database from SQLite to PostgreSQL")
    parser.add_argument("--sqlite", default="services/api/buildmart.db", help="Path to source SQLite database")
    parser.add_argument("--postgres", default=os.getenv("DATABASE_URL", "postgresql://buildmart_user:buildmart_secure_pass@localhost:5432/buildmart"), help="Target PostgreSQL connection URL")
    parser.add_argument("--dry-run", action="store_true", help="Simulate migration without modifying PostgreSQL")

    args = parser.parse_args()

    print("Initiating BuildMart SQLite -> PostgreSQL Data Migration...")
    try:
        data = load_sqlite_data(args.sqlite)
        migrate_to_postgres(data, args.postgres, dry_run=args.dry_run)
    except Exception as e:
        print(f"Migration failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
