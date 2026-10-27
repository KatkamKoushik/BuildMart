import json
import random

def fix_prices():
    # It's at assets/seeded_data.json, NOT assets/data/seeded_data.json!
    with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    for p in data.get('products', []):
        cat = p.get('categoryId', '')
        
        if cat == 'cement':
            new_price = random.randint(350, 450)
        elif cat == 'steel':
            new_price = random.randint(4000, 6000)
        elif cat == 'bricks_blocks':
            new_price = random.randint(10, 80)
        elif cat == 'sand_aggregates':
            new_price = random.randint(1000, 3000)
        elif cat == 'plumbing':
            new_price = random.randint(50, 1500)
        elif cat == 'electricals':
            new_price = random.randint(20, 2000)
        elif cat == 'paints':
            new_price = random.randint(300, 3000)
        elif cat == 'tiles_stone':
            new_price = random.randint(40, 150)
        else:
            new_price = random.randint(100, 2000)
            
        p['price'] = float(new_price)
        if 'originalPrice' in p:
            p['originalPrice'] = float(round(new_price * 1.1))

    with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
        
    print("Fixed prices.")

if __name__ == '__main__':
    fix_prices()
