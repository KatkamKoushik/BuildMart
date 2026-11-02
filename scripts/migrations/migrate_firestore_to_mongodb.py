"""
BuildMart Database Migration & Seeding Utility
Migrates or seeds collections into Google Cloud Firestore with MongoDB compatibility (Enterprise edition).

Supports two ingestion modes:
1. Live migration from Google Cloud Firestore (Native Mode) via firebase-admin.
2. Direct local seeding from catalog JSON (e.g. mobile/assets/seeded_data.json).

Usage (Direct local catalog seed):
    python scripts/migrations/migrate_firestore_to_mongodb.py \
        --seed-file mobile/assets/seeded_data.json \
        --dest-uri "mongodb://buildmart-admin:<PASSWORD>@<HOST>:443/buildmart?loadBalanced=true&tls=true&retryWrites=false&authMechanism=SCRAM-SHA-256"

Usage (Live Firestore migration):
    python scripts/migrations/migrate_firestore_to_mongodb.py \
        --source-project buildmart-24c42 \
        --source-credentials path/to/firebase-credentials.json \
        --dest-uri "mongodb://buildmart-admin:<PASSWORD>@<HOST>:443/buildmart?loadBalanced=true&tls=true&retryWrites=false&authMechanism=SCRAM-SHA-256"
"""

import argparse
import datetime
import json
import os
import sys
from typing import Any, Dict, List

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    firebase_admin = None

try:
    from pymongo import MongoClient, UpdateOne
    from pymongo.errors import PyMongoError
except ImportError:
    MongoClient = None
    UpdateOne = None


def normalize_value(val: Any) -> Any:
    """
    Recursively converts Firestore types (Timestamps, GeoPoints, DocumentReferences)
    into standard Python/BSON types compatible with MongoDB wire protocol.
    """
    if val is None:
        return None

    if hasattr(val, "to_datetime"):
        return val.to_datetime()
    if isinstance(val, (datetime.datetime, datetime.date)):
        return val

    if hasattr(val, "latitude") and hasattr(val, "longitude"):
        return {
            "type": "Point",
            "coordinates": [val.longitude, val.latitude],
            "latitude": val.latitude,
            "longitude": val.longitude,
        }

    if hasattr(val, "id") and hasattr(val, "path"):
        return {"_ref_path": val.path, "id": val.id}

    if isinstance(val, dict):
        return {k: normalize_value(v) for k, v in val.items()}

    if isinstance(val, list):
        return [normalize_value(item) for item in val]

    return val


def seed_from_file(dest_db: Any, file_path: str, batch_size: int = 500) -> int:
    """
    Reads catalog entities from a JSON file and bulk-upserts into MongoDB-compatible Firestore.
    """
    print(f"[*] Reading seed data from '{file_path}'...")
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    total_seeded = 0
    now = datetime.datetime.now(datetime.timezone.utc)

    for collection_name, items in data.items():
        if not isinstance(items, list) or not items:
            continue

        print(f"[*] Seeding collection '{collection_name}' ({len(items)} items)...")
        dest_col = dest_db[collection_name]
        bulk_ops: List[UpdateOne] = []
        col_count = 0

        for item in items:
            if not isinstance(item, dict):
                continue
            doc_id = str(item.get("id") or item.get("_id") or f"{collection_name}_{col_count}")
            normalized = normalize_value(item)

            bulk_ops.append(
                UpdateOne(
                    {"_id": doc_id},
                    {"$set": {**normalized, "_seeded_at": now}},
                    upsert=True,
                )
            )

            if len(bulk_ops) >= batch_size:
                dest_col.bulk_write(bulk_ops, ordered=False)
                col_count += len(bulk_ops)
                bulk_ops.clear()

        if bulk_ops:
            dest_col.bulk_write(bulk_ops, ordered=False)
            col_count += len(bulk_ops)
            bulk_ops.clear()

        print(f"[+] Completed seeding '{collection_name}': {col_count} records upserted.\n")
        total_seeded += col_count

    return total_seeded


def migrate_collection(
    source_db: Any,
    dest_db: Any,
    collection_name: str,
    batch_size: int = 500,
) -> int:
    """
    Streams documents from a native Firestore collection and performs idempotent
    bulk upserts into the destination MongoDB-compatible collection.
    """
    print(f"[*] Starting live migration for collection: '{collection_name}'...")
    source_ref = source_db.collection(collection_name)
    docs_stream = source_ref.stream()

    dest_col = dest_db[collection_name]
    bulk_ops: List[UpdateOne] = []
    migrated_count = 0
    now = datetime.datetime.now(datetime.timezone.utc)

    for doc in docs_stream:
        doc_data = doc.to_dict() or {}
        normalized = normalize_value(doc_data)
        doc_id = doc.id

        bulk_ops.append(
            UpdateOne(
                {"_id": doc_id},
                {"$set": {**normalized, "_firestore_migrated_at": now}},
                upsert=True,
            )
        )

        if len(bulk_ops) >= batch_size:
            dest_col.bulk_write(bulk_ops, ordered=False)
            migrated_count += len(bulk_ops)
            print(f"  [-] Progress '{collection_name}': {migrated_count} records upserted.")
            bulk_ops.clear()

    if bulk_ops:
        dest_col.bulk_write(bulk_ops, ordered=False)
        migrated_count += len(bulk_ops)
        print(f"  [-] Progress '{collection_name}': {migrated_count} records upserted.")
        bulk_ops.clear()

    print(f"[+] Completed collection '{collection_name}': total {migrated_count} records migrated.\n")
    return migrated_count


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Migrate or seed data into Firestore with MongoDB Compatibility."
    )
    parser.add_argument(
        "--seed-file",
        default="",
        help="Path to local JSON catalog file (e.g. mobile/assets/seeded_data.json) to seed directly.",
    )
    parser.add_argument(
        "--source-project",
        default=os.getenv("SOURCE_FIREBASE_PROJECT_ID", "buildmart-24c42"),
        help="Source Google Cloud / Firebase project ID for live migration.",
    )
    parser.add_argument(
        "--source-credentials",
        default=os.getenv("SOURCE_FIREBASE_CREDENTIALS", "firebase-credentials.json"),
        help="Path to GCP service account JSON key for source Firestore.",
    )
    parser.add_argument(
        "--dest-uri",
        default=os.getenv("DEST_MONGODB_URI", ""),
        help="MongoDB wire-protocol connection string for destination Firestore.",
    )
    parser.add_argument(
        "--dest-db",
        default=os.getenv("DEST_MONGODB_DB", "buildmart"),
        help="Destination database name inside MongoDB-compatible Firestore.",
    )
    parser.add_argument(
        "--collections",
        nargs="+",
        default=["categories", "brands", "products", "shops", "banners", "users", "orders"],
        help="List of Firestore collections to migrate in live migration mode.",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=500,
        help="Batch size for bulk upsert operations.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if MongoClient is None:
        print("Missing required dependency: pymongo. Install via: pip install pymongo", file=sys.stderr)
        sys.exit(1)

    if not args.dest_uri:
        print("Error: --dest-uri is required.", file=sys.stderr)
        sys.exit(1)

    # 1. Connect to destination MongoDB-compatible Firestore
    print("[*] Connecting to destination MongoDB-compatible Firestore...")
    mongo_client = MongoClient(args.dest_uri, serverSelectionTimeoutMS=10000)
    dest_db = mongo_client[args.dest_db]

    try:
        ping_res = dest_db.command("ping")
        print(f"[+] Successfully authenticated and connected via MongoDB wire protocol: {ping_res}")
    except Exception as e:
        print(f"[!] Connection or authentication failed to destination: {e}", file=sys.stderr)
        sys.exit(1)

    # 2. Mode A: Direct Seed from File
    if args.seed_file:
        if not os.path.exists(args.seed_file):
            print(f"[!] Error: Seed file '{args.seed_file}' does not exist.", file=sys.stderr)
            sys.exit(1)
        total = seed_from_file(dest_db=dest_db, file_path=args.seed_file, batch_size=args.batch_size)
        print(f"[*] Seeding finished. Total records inserted/updated: {total}")
        return

    # 3. Mode B: Live Firestore Migration
    if firebase_admin is None:
        print("Missing dependency for live Firestore migration: firebase-admin. Install via: pip install firebase-admin", file=sys.stderr)
        sys.exit(1)

    print(f"[*] Initializing source Firestore connection (Project: {args.source_project})...")
    if os.path.exists(args.source_credentials):
        cred = credentials.Certificate(args.source_credentials)
        source_app = firebase_admin.initialize_app(cred, {"projectId": args.source_project}, name="source_firestore")
    else:
        print(f"[!] Credentials file '{args.source_credentials}' not found. Attempting Application Default Credentials (ADC).")
        source_app = firebase_admin.initialize_app(options={"projectId": args.source_project}, name="source_firestore")

    source_db = firestore.client(app=source_app)

    total_migrated = 0
    for col_name in args.collections:
        total_migrated += migrate_collection(
            source_db=source_db,
            dest_db=dest_db,
            collection_name=col_name,
            batch_size=args.batch_size,
        )

    print(f"[*] Migration completed successfully. Total records migrated across all collections: {total_migrated}")


if __name__ == "__main__":
    main()
