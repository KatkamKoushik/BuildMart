import json

def unify_categories():
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    mapping = {
        'cat_cement': 'cement',
        'cat_steel': 'steel',
        'cat_plumbing': 'plumbing',
        'cat_paints': 'paints'
    }
    
    count = 0
    for p in data.get('products', []):
        cat_id = p.get('categoryId')
        if cat_id in mapping:
            p['categoryId'] = mapping[cat_id]
            count += 1
            
    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
        
    print(f"Updated category for {count} products!")

if __name__ == "__main__":
    unify_categories()
