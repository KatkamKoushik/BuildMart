"""
MongoDB / Firestore Enterprise MongoDB Compatibility Connection Module
Provides thread-safe connection pooling, database access, and health verification.
"""
from typing import Any, Optional
import pymongo
from app.core.config import settings

_mongo_client: Optional[pymongo.MongoClient] = None


def get_mongo_client() -> Optional[pymongo.MongoClient]:
    global _mongo_client
    if not settings.MONGODB_URI:
        return None
    if _mongo_client is None:
        _mongo_client = pymongo.MongoClient(
            settings.MONGODB_URI,
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=5000,
            socketTimeoutMS=10000,
            maxPoolSize=50,
            minPoolSize=5,
        )
    return _mongo_client


def get_mongo_db() -> Optional[Any]:
    client = get_mongo_client()
    if client is not None:
        return client[settings.MONGODB_DB_NAME]
    return None


def check_mongo_health() -> bool:
    try:
        client = get_mongo_client()
        if client is not None:
            client.admin.command("ping")
            return True
        return False
    except Exception as e:
        print(f"[MongoDB Health] Connectivity check failed: {e}")
        return False


def close_mongo_connection() -> None:
    global _mongo_client
    if _mongo_client is not None:
        _mongo_client.close()
        _mongo_client = None
