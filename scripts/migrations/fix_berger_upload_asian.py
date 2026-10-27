import json
import os
import re
import cloudinary
import cloudinary.uploader

cloudinary.config(
  cloud_name = os.getenv('CLOUDINARY_CLOUD_NAME', 'snwiu5gv'),
  api_key = os.getenv('CLOUDINARY_API_KEY', ''),
  api_secret = os.getenv('CLOUDINARY_API_SECRET', '')
)

def clean_name(filename):
    name = filename.split('.')[0]
    name = re.sub(r'_\d+', '', name)
    name = name.replace('_', ' ')
    name = name.replace(' (1)', '')
    name = name.replace('', '')
    name = name.strip()
    return name

def run_fix():
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    # Fix Berger
    for p in data.get('products', []):
        if p.get('brand') == 'cat_paints' and p.get('categoryId') == 'paints':
            p['brand'] = 'berger'
            
    # Add Asian Paints
    base_dir = r"assets\images\products\asian paints"
    
    last_id = 0
    for p in data.get('products', []):
        if p['id'].startswith('prod_'):
            try:
                num = int(p['id'].split('_')[1])
                if num > last_id: last_id = num
            except: pass
            
    seen_names = set([p.get('name') for p in data.get('products', [])])
    products_to_add = []
    
    if os.path.exists(base_dir):
        for f in os.listdir(base_dir):
            if f.endswith(('.jpeg', '.jpg', '.png')):
                filepath = os.path.join(base_dir, f)
                c_name = clean_name(f)
                
                final_name = c_name
                counter = 2
                while final_name in seen_names:
                    final_name = f"{c_name} {counter}"
                    counter += 1
                seen_names.add(final_name)
                
                print(f"Uploading {final_name}...")
                try:
                    response = cloudinary.uploader.upload(filepath, folder="buildmart_app/products")
                    url = response['secure_url']
                    
                    last_id += 1
                    new_prod_id = f"prod_{last_id:03d}"
                    
                    new_prod = {
                        "id": new_prod_id,
                        "title": final_name,
                        "name": final_name,
                        "description": f"High quality {final_name} by Asian Paints.",
                        "price": 850,
                        "originalPrice": 1050,
                        "rating": 4.8,
                        "reviews": 15,
                        "totalReviews": 15,
                        "imageUrls": [url],
                        "imageUrl": url,
                        "categoryId": 'paints',
                        "brand": 'asian_paints',
                        "inStock": True,
                        "unit": "Bucket",
                        "deliveryTime": "1-2 days"
                    }
                    products_to_add.append(new_prod)
                except Exception as e:
                    print(f"Error uploading {f}: {e}")
                    
    data['products'].extend(products_to_add)
    
    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
        
    print(f"Added {len(products_to_add)} Asian Paints products. Berger paints fixed.")

if __name__ == '__main__':
    run_fix()
