import json

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

fixes = {
    'prod_046': {'title': 'General Purpose Wood Primer', 'name': 'General Purpose Wood Primer'},
    'prod_047': {'title': 'Exterior Wall Paint', 'name': 'Exterior Wall Paint'},
    'prod_048': {'title': 'Wall Primer - Interior/Exterior', 'name': 'Wall Primer - Interior/Exterior'},
    'prod_050': {'title': 'Liquid Waterproofing Chemical', 'name': 'Liquid Waterproofing Chemical'},
    'prod_052': {'title': 'Wall Crack Filler Paste', 'name': 'Wall Crack Filler Paste'},
    
    # cy2delwezfnbtey1xgrg.jpg (Wooden Planks)
    'prod_door_001': {'title': 'Wooden Planks Bundle', 'name': 'Wooden Planks Bundle'},
    'prod_door_003': {'title': 'Hardwood Planks', 'name': 'Hardwood Planks'},
    
    # vilfefofj7tz5l4ngmha.jpg (Teak Wood Door)
    'prod_door_002': {'title': 'Teak Wood Main Door', 'name': 'Teak Wood Main Door'},
    'prod_door_004': {'title': 'Teak Wood Internal Door', 'name': 'Teak Wood Internal Door'},
    'prod_door_005': {'title': 'Premium Teak Wood Door', 'name': 'Premium Teak Wood Door'},
}

for prod in data.get('products', []):
    if prod['id'] in fixes:
        prod['title'] = fixes[prod['id']]['title']
        prod['name'] = fixes[prod['id']]['name']

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print("Paints and Doors fixed successfully.")
