import json, os
from collections import Counter

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print('--- Banners ---')
print(f"Banners in JSON: {len(data.get('banners', []))}")
banner_dir = 'assets/images/BuildMart Home Banners'
banner_files = [f for f in os.listdir(banner_dir) if f.endswith('.png') or f.endswith('.jpeg')]
print(f"Banner images on disk: {len(banner_files)}")

print('\n--- Products ---')
print(f"Products in JSON: {len(data.get('products', []))}")
product_dir = 'assets/images/product images'
total_product_images = 0
for cat_folder in os.listdir(product_dir):
    cat_path = os.path.join(product_dir, cat_folder)
    if os.path.isdir(cat_path):
        images = [f for f in os.listdir(cat_path) if f.endswith('.png') or f.endswith('.jpeg') or f.endswith('.jpg')]
        total_product_images += len(images)
        print(f"Folder '{cat_folder}': {len(images)} images")
        
print(f"\nTotal product images on disk: {total_product_images}")

print('\n--- Products per category in JSON ---')
cat_counts = Counter([p.get('categoryId') for p in data.get('products', [])])
for cat, count in cat_counts.items():
    print(f"Category '{cat}': {count} products")
