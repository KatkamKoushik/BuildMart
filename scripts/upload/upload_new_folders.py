import json
import os
import cloudinary
import cloudinary.uploader
import re

cloudinary.config(
  cloud_name = 'snwiu5gv',
  api_key = '969328414263883',
  api_secret = 'oLK_6m_Z6iTG78ZWK5CVcVtFAxI'
)

BRAND_INFO = {
    'CenturyDoors': ('centurydoors', 'doors_glass', 'CenturyDoors'),
    'Fenesta': ('fenesta', 'doors_glass', 'Fenesta'),
    'Greenply': ('greenply', 'wood_boards', 'Greenply'),
    'Jaquar': ('jaquar', 'plumbing', 'Jaquar'),
    'Saint-Gobain': ('saint_gobain', 'doors_glass', 'Saint-Gobain')
}

def clean_name(filename):
    name = filename.split('.')[0]
    name = re.sub(r'_\d+', '', name)
    name = name.replace('_', ' ')
    name = name.replace(' (1)', '')
    name = name.replace('', '')
    name = name.strip()
    return name

def upload():
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    products_to_add = []
    
    last_id = 0
    for p in data.get('products', []):
        if p['id'].startswith('prod_'):
            try:
                num = int(p['id'].split('_')[1])
                if num > last_id:
                    last_id = num
            except:
                pass
                
    base_dir = r"assets\images\products"
    
    for brand_folder in BRAND_INFO.keys():
        folder_path = os.path.join(base_dir, brand_folder)
        if not os.path.exists(folder_path):
            continue
            
        brand_id, cat_id, brand_name = BRAND_INFO[brand_folder]
        
        for filename in os.listdir(folder_path):
            filepath = os.path.join(folder_path, filename)
            if not os.path.isfile(filepath):
                continue
                
            product_name = clean_name(filename)
            print(f"Uploading {product_name}...")
            
            try:
                response = cloudinary.uploader.upload(filepath, folder="buildmart_app/products")
                url = response['secure_url']
                
                last_id += 1
                new_prod_id = f"prod_{last_id:03d}"
                
                new_prod = {
                    "id": new_prod_id,
                    "title": product_name,
                    "name": product_name,
                    "description": f"High quality {product_name} by {brand_name}.",
                    "price": 800,
                    "originalPrice": 1000,
                    "rating": 4.8,
                    "reviews": 15,
                    "totalReviews": 15,
                    "imageUrls": [url],
                    "imageUrl": url,
                    "categoryId": cat_id,
                    "brand": brand_id,
                    "inStock": True,
                    "unit": "Piece",
                    "deliveryTime": "1-2 days"
                }
                products_to_add.append(new_prod)
            except Exception as e:
                print(f"Error uploading {filename}: {e}")
                
    if 'products' not in data:
        data['products'] = []
    data['products'].extend(products_to_add)
    
    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
        
    print(f"Added {len(products_to_add)} products!")

if __name__ == "__main__":
    upload()
