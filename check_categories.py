import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Initialize Firebase
if not firebase_admin._apps:
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

# Fetch categories
categories = list(db.collection('categories').stream())
print("Categories:")
category_ids = []
for cat in categories:
    print(f"ID: {cat.id}, Name: {cat.to_dict().get('name')}")
    category_ids.append(cat.id)

# Fetch products and their categoryId
products = list(db.collection('products').stream())
print("\nProducts:")
for p in products:
    data = p.to_dict()
    print(f"Product: {data.get('title')}, categoryId: {data.get('categoryId')}")
