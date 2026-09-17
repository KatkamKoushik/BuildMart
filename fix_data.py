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

# Mapping of file names to standard brand IDs and Names
FILE_TO_BRAND = {
    'Ambuja_Cements.svg': ('ambuja', 'Ambuja Cements'),
    'Astral-Pipes-Logo-PNG-SVG-Vector.png': ('astral', 'Astral Pipes'),
    'CenturyDoors.jpg': ('centurydoors', 'CenturyDoors'),
    'Greenply_logo.svg.webp': ('greenply', 'Greenply'),
    'JAQUAR_spirintoise_logo.png': ('jaquar', 'Jaquar'),
    'Ultratech_Cement_Logo.svg.webp': ('ultratech', 'UltraTech'),
    'acc-cement.avif': ('acc', 'ACC Cement'),
    'asian paints.jpg': ('asian_paints', 'Asian Paints'),
    'berger-paints-vector-logo.png': ('berger', 'Berger Paints'),
    'fenesta-logo-png_seeklogo-549369.png': ('fenesta', 'Fenesta'),
    'penna.jpg': ('penna', 'Penna Cement'),
    'priya cement.jpg': ('priya', 'Priya Cement'),
    'ramco.jpg': ('ramco', 'Ramco'),
    'saint gobain.jpg': ('saint_gobain', 'Saint-Gobain'),
    'supreme pipes.jpg': ('supreme', 'Supreme Pipes'),
    'tata tiscon.jpg': ('tata_tiscon', 'Tata Tiscon'),
    'tata-steel-logo.png': ('tata_steel', 'Tata Steel'),
    'the-kcp-ltd-jubilee-hills-hyderabad-cement-distributors-ymiqb1k3ad-250.avif': ('kcp', 'KCP Cement')
}

def clean_product_brand(brand_str):
    if not brand_str: return None
    b = brand_str.lower().strip()
    if 'tata' in b and 'tiscon' in b: return 'tata_tiscon'
    if 'tata' in b: return 'tata_steel'
    if 'saint' in b and 'gobain' in b: return 'saint_gobain'
    if 'century' in b: return 'centurydoors'
    if 'greenply' in b: return 'greenply'
    if 'fenesta' in b: return 'fenesta'
    if 'jaquar' in b: return 'jaquar'
    if 'ultra' in b: return 'ultratech'
    if 'asian' in b: return 'asian_paints'
    if 'ambuja' in b: return 'ambuja'
    if 'acc' in b: return 'acc'
    if 'berger' in b: return 'berger'
    if 'astral' in b: return 'astral'
    if 'ramco' in b: return 'ramco'
    if 'priya' in b: return 'priya'
    if 'kcp' in b: return 'kcp'
    if 'penna' in b: return 'penna'
    if 'supreme' in b: return 'supreme'
    return b

def upload_images():
    print("Uploading logos to Cloudinary...")
    logo_dir = r"assets\images\brand logo"
    brand_urls = {}
    
    for filename in os.listdir(logo_dir):
        if filename in FILE_TO_BRAND:
            filepath = os.path.join(logo_dir, filename)
            brand_id, brand_name = FILE_TO_BRAND[filename]
            try:
                print(f"Uploading {filename}...")
                response = cloudinary.uploader.upload(filepath, folder="buildmart_app/brands")
                brand_urls[brand_id] = response['secure_url']
            except Exception as e:
                print(f"Failed to upload {filename}: {e}")
    return brand_urls

def process_data(brand_urls):
    print("Processing seeded_data.json...")
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # 1. Update Brands list
    brands_dict = {b['id']: b for b in data.get('brands', [])}
    
    for filename, (brand_id, brand_name) in FILE_TO_BRAND.items():
        url = brand_urls.get(brand_id)
        if url:
            if brand_id in brands_dict:
                brands_dict[brand_id]['logoUrl'] = url
                brands_dict[brand_id]['name'] = brand_name
            else:
                brands_dict[brand_id] = {
                    'id': brand_id,
                    'name': brand_name,
                    'logoUrl': url
                }
                
    data['brands'] = list(brands_dict.values())
    
    # 2. Update Products
    for p in data.get('products', []):
        # standardize brand id
        if 'brand' in p:
            standard_id = clean_product_brand(p['brand'])
            if standard_id:
                p['brand'] = standard_id
                
        # Fix Generic Names
        generic_names = ['cement', 'steel', 'bricks', 'sand', 'paint', 'tiles']
        p_name = p.get('title', p.get('name', '')).strip()
        if p_name.lower() in generic_names and 'brand' in p:
            brand_id = p['brand']
            brand_info = brands_dict.get(brand_id)
            if brand_info:
                new_name = f"{brand_info['name']} {p_name}"
                p['name'] = new_name
                p['title'] = new_name

    # Save changes
    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
    print("Updated assets/seeded_data.json successfully!")

def main():
    urls = upload_images()
    process_data(urls)

if __name__ == "__main__":
    main()
