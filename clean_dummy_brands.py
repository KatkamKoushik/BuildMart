import json

def fix_brands():
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    brand_keywords = {
        'acc': ['acc'],
        'asian_paints': ['asian'],
        'berger': ['berger'],
        'jaquar': ['jaquar'],
        'astral': ['astral'],
        'ramco': ['ramco'],
        'priya': ['priya'],
        'kcp': ['kcp'],
        'penna': ['penna'],
        'supreme': ['supreme'],
        'ultratech': ['ultratech', 'ultra tech'],
        'ambuja': ['ambuja'],
        'centurydoors': ['century'],
        'greenply': ['greenply'],
        'fenesta': ['fenesta'],
        'saint_gobain': ['saint gobain', 'saint-gobain'],
        'tata_tiscon': ['tiscon'],
        'tata_steel': ['tata steel', 'tata']
    }
    
    count = 0
    for p in data.get('products', []):
        brand_id = p.get('brand')
        if not brand_id:
            continue
            
        name_lower = p.get('name', '').lower()
        
        is_valid = False
        if brand_id in brand_keywords:
            for kw in brand_keywords[brand_id]:
                if kw in name_lower:
                    is_valid = True
                    break
        else:
            kw = brand_id.replace('_', ' ')
            if kw in name_lower or brand_id in name_lower:
                is_valid = True
                
        if not is_valid:
            del p['brand']
            count += 1
            
    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
    print(f"Removed fake brand tags from {count} products!")

if __name__ == "__main__":
    fix_brands()
