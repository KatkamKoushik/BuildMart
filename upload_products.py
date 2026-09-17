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

# Mapping of file name keywords to brand ID and category ID
BRAND_RULES = {
    'acc': ('acc', 'cat_cement', 'ACC Cement'),
    'ambuja': ('ambuja', 'cat_cement', 'Ambuja Cements'),
    'kcp': ('kcp', 'cat_cement', 'KCP Cement'),
    'penna': ('penna', 'cat_cement', 'Penna Cement'),
    'priya': ('priya', 'cat_cement', 'Priya Cement'),
    'ramco': ('ramco', 'cat_cement', 'Ramco'),
    'astral': ('astral', 'cat_plumbing', 'Astral Pipes'),
    'supreme': ('supreme', 'cat_plumbing', 'Supreme Pipes'),
    'berger': ('berger', 'cat_paints', 'Berger Paints'),
    'tata_tiscon': ('tata_tiscon', 'cat_steel', 'Tata Tiscon'),
    'tata_steel': ('tata_steel', 'cat_steel', 'Tata Steel'),
    'tata': ('tata_steel', 'cat_steel', 'Tata Steel'), # generic tata fallback
    'steel': ('tata_steel', 'cat_steel', 'Tata Steel'), # generic steel fallback
    'binding_wire': ('tata_steel', 'cat_steel', 'Tata Steel'), # generic steel fallback
}

def clean_name(filename):
    name = filename.split('.')[0]
    name = re.sub(r'_\d+', '', name) # remove timestamps like 202608131536
    name = name.replace('_', ' ')
    name = name.replace(' (1)', '')
    name = name.strip()
    return name

def upload_images():
    print("Uploading product images to Cloudinary...")
    img_dir = r"assets\images\products"
    
    products_to_add = []
    
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    last_id = 0
    for p in data.get('products', []):
        if p['id'].startswith('prod_'):
            try:
                num = int(p['id'].split('_')[1])
                if num > last_id:
                    last_id = num
            except:
                pass
                
    for filename in os.listdir(img_dir):
        # We process (1) files as well unless told otherwise
        filepath = os.path.join(img_dir, filename)
        
        # determine brand and category
        fn_lower = filename.lower()
        brand_id = None
        category_id = None
        brand_name = ''
        
        # special case for tata tiscon
        if 'tiscon' in fn_lower:
            brand_id, category_id, brand_name = BRAND_RULES['tata_tiscon']
        else:
            for k, v in BRAND_RULES.items():
                if k in fn_lower:
                    brand_id, category_id, brand_name = v
                    break
                    
        if not brand_id:
            brand_id = 'generic'
            category_id = 'cat_materials' # generic
            brand_name = 'Generic'
            
        product_name = clean_name(filename)
        
        try:
            print(f"Uploading {filename}...")
            response = cloudinary.uploader.upload(filepath, folder="buildmart_app/products")
            url = response['secure_url']
            
            last_id += 1
            new_prod_id = f"prod_{last_id:03d}"
            
            new_prod = {
                "id": new_prod_id,
                "title": product_name,
                "name": product_name,
                "description": f"High quality {product_name} by {brand_name}.",
                "price": 500, # Dummy price
                "originalPrice": 600,
                "rating": 4.5,
                "reviews": 12,
                "totalReviews": 12,
                "imageUrls": [url],
                "imageUrl": url,
                "categoryId": category_id,
                "brand": brand_id,
                "inStock": True,
                "unit": "Piece",
                "deliveryTime": "1-2 days"
            }
            products_to_add.append(new_prod)
        except Exception as e:
            print(f"Failed to upload {filename}: {e}")
            
    # Append to data
    if 'products' not in data:
        data['products'] = []
        
    data['products'].extend(products_to_add)
    
    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
        
    print(f"Added {len(products_to_add)} products successfully!")

if __name__ == "__main__":
    upload_images()
