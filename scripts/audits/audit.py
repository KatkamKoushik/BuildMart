import json
import cloudinary
import cloudinary.api
import os

cloudinary.config(
  cloud_name = os.getenv('CLOUDINARY_CLOUD_NAME', 'snwiu5gv'),
  api_key = os.getenv('CLOUDINARY_API_KEY', ''),
  api_secret = os.getenv('CLOUDINARY_API_SECRET', '')
)

def main():
    try:
        with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading JSON: {e}")
        return

    # 1. Fetch all Cloudinary images
    print("Fetching Cloudinary images...")
    cloudinary_images = []
    try:
        next_cursor = None
        while True:
            response = cloudinary.api.resources(type="upload", max_results=500, next_cursor=next_cursor)
            cloudinary_images.extend([r['secure_url'] for r in response.get('resources', [])])
            next_cursor = response.get('next_cursor')
            if not next_cursor:
                break
    except Exception as e:
        print(f"Error fetching Cloudinary images: {e}")
        return

    print(f"Found {len(cloudinary_images)} images in Cloudinary.")

    # 2. Extract used images
    used_images = set()
    brands = data.get('brands', [])
    categories = data.get('categories', [])
    products = data.get('products', [])

    for b in brands:
        if 'logoUrl' in b:
            used_images.add(b['logoUrl'])
    for c in categories:
        if 'imageUrl' in c:
            used_images.add(c['imageUrl'])
    for p in products:
        if 'imageUrl' in p:
            used_images.add(p['imageUrl'])

    # 3. Analyze Brand Mismatches
    brand_ids = set(b['id'] for b in brands)
    product_brand_ids = set(p.get('brandId') for p in products if p.get('brandId'))
    brands_without_products = brand_ids - product_brand_ids
    products_without_brands = [p['name'] for p in products if not p.get('brandId')]

    # 4. Analyze Category Mismatches (Same Image, Multiple Names)
    category_image_map = {}
    category_mismatches = []
    for c in categories:
        img = c.get('imageUrl')
        if img in category_image_map:
            category_mismatches.append(f"Image {img} used by '{category_image_map[img]}' and '{c['name']}'")
        else:
            category_image_map[img] = c['name']

    # 5. Analyze Naming Issues (Generic names like "Cement")
    generic_names = [p['name'] for p in products if p['name'].strip().lower() in ['cement', 'steel', 'bricks', 'sand', 'paint']]
    
    # 6. Analyze Brands Without Logos (Or using placeholder logos)
    brands_without_logos = [b['name'] for b in brands if 'logoUrl' not in b or 'unsplash' in b['logoUrl'] or 'placeholder' in b['logoUrl']]

    # Write report
    with open('audit_report.txt', 'w', encoding='utf-8') as f:
        f.write(f"--- CLOUDINARY AUDIT ---\n")
        f.write(f"Total Cloudinary Images: {len(cloudinary_images)}\n")
        f.write(f"Images Used in App (seeded_data): {len(used_images)}\n")
        unused = set(cloudinary_images) - used_images
        f.write(f"Unused Cloudinary Images: {len(unused)}\n\n")
        
        f.write(f"--- BRAND AUDIT ---\n")
        f.write(f"Brands without Products: {brands_without_products}\n")
        f.write(f"Products without Brands ({len(products_without_brands)}): {products_without_brands[:10]}...\n")
        f.write(f"Brands without Logos (or using placeholders): {brands_without_logos}\n\n")

        f.write(f"--- CATEGORY AUDIT ---\n")
        f.write(f"Category Image Mismatches:\n")
        for m in category_mismatches:
            f.write(f"  - {m}\n")
        f.write("\n")

        f.write(f"--- PRODUCT NAMING AUDIT ---\n")
        f.write(f"Generic Product Names: {generic_names}\n")

    print("Audit report written to audit_report.txt")

if __name__ == "__main__":
    main()
