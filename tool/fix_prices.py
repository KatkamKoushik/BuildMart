import json
import re

SEEDED_DATA_PATH = r"assets\seeded_data.json"

def get_realistic_price(name):
    name = name.lower()
    if 'cement' in name and 'brick' not in name:
        return 380.0
    if 'aac block' in name or 'concrete block' in name:
        return 65.0
    if 'red clay brick' in name:
        return 8.0
    if 'fly ash brick' in name:
        return 6.0
    if 'sand' in name: # per ton
        return 1200.0
    if 'gravel' in name or 'aggregate' in name or 'crushed stone' in name:
        return 800.0
    if 'steel' in name and 'bar' in name:
        return 65.0
    if 'putty' in name:
        return 750.0
    if 'adhesive' in name:
        return 450.0
    if 'paint' in name:
        return 1500.0
    if 'primer' in name:
        return 1200.0
    if 'pipe' in name:
        return 400.0
    if 'plywood' in name:
        return 1500.0
    if 'board' in name:
        return 1000.0
    if 'wood' in name or 'timber' in name:
        return 2000.0
    if 'door' in name:
        return 3500.0
    if 'tile' in name: # per box
        return 600.0
    if 'marble' in name or 'granite' in name:
        return 2500.0
    if 'switch' in name or 'socket' in name:
        return 150.0
    if 'wire' in name or 'cable' in name:
        return 1200.0
    if 'bulb' in name:
        return 150.0
    if 'helmet' in name or 'safety' in name:
        return 500.0
    if 'hammer' in name or 'wrench' in name or 'tool' in name:
        return 300.0
    if 'nail' in name or 'screw' in name or 'bolt' in name:
        return 150.0
    
    return 500.0

def main():
    with open(SEEDED_DATA_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    for item in data.get('products', []):
        new_price = get_realistic_price(item['name'])
        item['price'] = new_price
        if 'originalPrice' in item:
            item['originalPrice'] = round(new_price * 1.2, 2)
            
    with open(SEEDED_DATA_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
        
    print("Prices updated to realistic INR values.")

if __name__ == "__main__":
    main()
