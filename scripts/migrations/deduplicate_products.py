import json

def deduplicate():
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    products = data.get('products', [])
    
    seen_names = set()
    unique_products = []
    
    for p in products:
        name = p.get('name', '')
        if name not in seen_names:
            seen_names.add(name)
            unique_products.append(p)
            
    print(f"Original product count: {len(products)}")
    print(f"Unique product count: {len(unique_products)}")
    
    data['products'] = unique_products
    
    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
        
if __name__ == '__main__':
    deduplicate()
