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

BRAND_INFO = {
    'CenturyDoors': ('centurydoors', 'doors_glass', 'CenturyDoors'),
    'Fenesta': ('fenesta', 'doors_glass', 'Fenesta'),
    'Greenply': ('greenply', 'wood_boards', 'Greenply'),
    'Jaquar': ('jaquar', 'plumbing', 'Jaquar'),
    'Saint-Gobain': ('saint_gobain', 'doors_glass', 'Saint-Gobain')
}

BRAND_RULES = {
    'acc': ('acc', 'cat_cement', 'ACC Cement'),
    'ambuja': ('ambuja', 'cat_cement', 'Ambuja Cements'),
    'kcp': ('kcp', 'cat_cement', 'KCP Cement'),
    'penna': ('penna', 'cat_cement', 'Penna Cement'),
    'priya': ('priya', 'cat_cement', 'Priya Cement'),
    'ramco': ('ramco', 'cat_cement', 'Ramco'),
    'astral': ('astral', 'cat_plumbing', 'Astral Pipes'),
    'supreme': ('supreme', 'cat_plumbing', 'Supreme Pipes'),
    'berger': ('cat_paints', 'paints', 'Berger Paints'),
    'tata_tiscon': ('tata_tiscon', 'cat_steel', 'Tata Tiscon'),
    'tata_steel': ('tata_steel', 'cat_steel', 'Tata Steel'),
    'tata': ('tata_steel', 'cat_steel', 'Tata Steel'),
    'steel': ('tata_steel', 'cat_steel', 'Tata Steel'),
    'binding_wire': ('tata_steel', 'cat_steel', 'Tata Steel'),
}

def clean_name(filename):
    name = filename.split('.')[0]
    name = re.sub(r'_\d+', '', name)
    name = name.replace('_', ' ')
    name = name.replace(' (1)', '')
    name = name.replace('', '')
    name = name.strip()
    return name

def restore():
    base_dir = r"assets\images\products"
    
    # 1. Gather all local files and their base names
    local_files = []
    base_names = set()
    for root, _, files in os.walk(base_dir):
        for f in files:
            if f.endswith(('.jpeg', '.jpg', '.png')):
                filepath = os.path.join(root, f)
                c_name = clean_name(f)
                base_names.add(c_name)
                
                # Determine brand info
                brand_id, cat_id, brand_name = 'generic', 'cat_materials', 'Generic'
                
                # check if in subfolder
                rel_dir = os.path.relpath(root, base_dir)
                if rel_dir in BRAND_INFO:
                    brand_id, cat_id, brand_name = BRAND_INFO[rel_dir]
                else:
                    fn_lower = f.lower()
                    if 'tiscon' in fn_lower:
                        brand_id, cat_id, brand_name = BRAND_RULES['tata_tiscon']
                    else:
                        for k, v in BRAND_RULES.items():
                            if k in fn_lower:
                                brand_id, cat_id, brand_name = v
                                break
                                
                # apply my mapping for categories
                if cat_id == 'cat_cement': cat_id = 'cement'
                elif cat_id == 'cat_steel': cat_id = 'steel'
                elif cat_id == 'cat_plumbing': cat_id = 'plumbing'
                elif cat_id == 'cat_paints': cat_id = 'paints'

                local_files.append((filepath, c_name, brand_id, cat_id, brand_name))

    # 2. Delete existing products that match these names
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    filtered_products = []
    for p in data.get('products', []):
        pname = p.get('name', '')
        # check if it matches a base name exactly, or base name + " " + number
        is_match = False
        for bn in base_names:
            if pname == bn or re.match(f"^{re.escape(bn)} \\d+$", pname):
                is_match = True
                break
        if not is_match:
            filtered_products.append(p)
            
    print(f"Removed {len(data.get('products', [])) - len(filtered_products)} existing products that clash with local files.")
    
    last_id = 0
    for p in filtered_products:
        if p['id'].startswith('prod_'):
            try:
                num = int(p['id'].split('_')[1])
                if num > last_id: last_id = num
            except: pass

    # 3. Upload all local files with unique names
    products_to_add = []
    seen_names = set([p.get('name') for p in filtered_products])
    
    for filepath, c_name, brand_id, cat_id, brand_name in local_files:
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
                "description": f"High quality {final_name} by {brand_name}.",
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
            print(f"Error uploading {filepath}: {e}")
            
    data['products'] = filtered_products + products_to_add
    
    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
        
    print(f"Added {len(products_to_add)} products! Total products now: {len(data['products'])}")

if __name__ == "__main__":
    restore()
