import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json

# Use a service account
cred = credentials.Certificate('buildmart-24c42-firebase-adminsdk-fbsvc-c831ddcd32.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

new_products = [
    {
        "id": "prod_door_002",
        "name": "Teak Wood Main Door",
        "title": "Teak Wood Main Door",
        "description": "Premium quality teak wood main door with elegant carvings. Highly durable and termite resistant.",
        "price": 25000,
        "originalPrice": 28000,
        "categoryId": "doors_glass",
        "brand": "CenturyDoors",
        "imageUrls": ["https://res.cloudinary.com/snwiu5gv/image/upload/v1786344600/buildmart_app/cy2delwezfnbtey1xgrg.jpg"],
        "unit": "Piece",
        "inStock": True,
        "stockQuantity": 15,
        "isFeatured": True,
        "specifications": {
            "Material": "Teak Wood",
            "Dimensions": "7x3 ft",
            "Thickness": "35mm"
        },
        "rating": 4.8,
        "reviewCount": 24
    },
    {
        "id": "prod_door_003",
        "name": "UPVC Sliding Window",
        "title": "UPVC Sliding Window",
        "description": "Energy-efficient UPVC sliding window with clear glass and sturdy frame.",
        "price": 4500,
        "categoryId": "doors_glass",
        "brand": "Fenesta",
        "imageUrls": ["https://res.cloudinary.com/snwiu5gv/image/upload/v1786344604/buildmart_app/vilfefofj7tz5l4ngmha.jpg"],
        "unit": "Sq Ft",
        "inStock": True,
        "stockQuantity": 30,
        "isFeatured": False,
        "specifications": {
            "Material": "UPVC",
            "Type": "Sliding",
            "Glass": "Clear, 5mm"
        },
        "rating": 4.5,
        "reviewCount": 18
    },
    {
        "id": "prod_door_004",
        "name": "Flush Door 30mm",
        "title": "Flush Door 30mm",
        "description": "Commercial grade flush door suitable for interior use. Moisture resistant.",
        "price": 1800,
        "originalPrice": 2100,
        "categoryId": "doors_glass",
        "brand": "Greenply",
        "imageUrls": ["https://res.cloudinary.com/snwiu5gv/image/upload/v1786344600/buildmart_app/cy2delwezfnbtey1xgrg.jpg"],
        "unit": "Piece",
        "inStock": True,
        "stockQuantity": 50,
        "isFeatured": False,
        "specifications": {
            "Material": "Plywood",
            "Dimensions": "7x3 ft",
            "Thickness": "30mm"
        },
        "rating": 4.2,
        "reviewCount": 42
    },
    {
        "id": "prod_door_005",
        "name": "Frosted Toughened Glass 12mm",
        "title": "Frosted Toughened Glass 12mm",
        "description": "High-strength 12mm frosted toughened glass for partitions and shower enclosures.",
        "price": 280,
        "categoryId": "doors_glass",
        "brand": "Saint-Gobain",
        "imageUrls": ["https://res.cloudinary.com/snwiu5gv/image/upload/v1786344604/buildmart_app/vilfefofj7tz5l4ngmha.jpg"],
        "unit": "Sq Ft",
        "inStock": True,
        "stockQuantity": 100,
        "isFeatured": False,
        "specifications": {
            "Material": "Toughened Glass",
            "Thickness": "12mm",
            "Finish": "Frosted"
        },
        "rating": 4.9,
        "reviewCount": 15
    }
]

print("Adding products to Firestore...")
for product in new_products:
    db.collection('products').document(product['id']).set(product)
    print(f"Added {product['name']}")

print("Updating seeded_data.json...")
with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Avoid duplicates
existing_ids = set(p['id'] for p in data['products'])
for product in new_products:
    if product['id'] not in existing_ids:
        data['products'].append(product)

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4)

print("Done.")
