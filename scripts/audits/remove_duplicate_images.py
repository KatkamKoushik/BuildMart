import json

def dedupe_by_image():
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    products = data.get('products', [])
    seen_images = set()
    unique_products = []
    
    for p in products:
        img = p.get('imageUrl')
        if not img and p.get('imageUrls'):
            img = p['imageUrls'][0]
            
        if not img:
            unique_products.append(p)
            continue
            
        if img not in seen_images:
            seen_images.add(img)
            unique_products.append(p)
        else:
            print(f"Removing product with duplicate image: {p.get('name')}")
            
    print(f"\nOriginal product count: {len(products)}")
    print(f"Unique product count after image deduplication: {len(unique_products)}")
    
    data['products'] = unique_products
    
    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
        
if __name__ == '__main__':
    dedupe_by_image()
