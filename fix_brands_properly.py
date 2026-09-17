import json

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for p in data['products']:
    cat = p.get('categoryId')
    name = p.get('name', '')
    old_brand = p.get('brand')
    
    # 1. Paint products should be asian_paints or berger
    if cat == 'paints':
        if 'berger' not in name.lower() and 'asian' not in name.lower():
            p['brand'] = 'asian_paints'
            
    # 2. Re-assign products that are currently asian_paints but shouldn't be
    if old_brand == 'asian_paints' and cat not in ['paints', 'waterproofing']:
        if cat == 'plumbing':
            p['brand'] = 'astral'
        elif cat == 'electricals':
            p['brand'] = 'jaquar'
        elif cat == 'hardware_tools' or cat == 'fasteners' or cat == 'steel' or cat == 'site_materials':
            p['brand'] = 'tata_steel'
        elif cat == 'safety_equipment':
            p['brand'] = 'tata_steel'
        elif cat == 'sand_aggregates':
            p['brand'] = 'ultratech'
        elif cat == 'tiles_stone':
            p['brand'] = 'ultratech'
        elif cat == 'wood_boards' or cat == 'doors_glass':
            p['brand'] = 'greenply' if 'ply' in name.lower() else 'centurydoors'
        else:
            p['brand'] = 'tata_tiscon'

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4)

print("Brands fixed successfully!")
