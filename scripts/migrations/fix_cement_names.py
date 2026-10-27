import json

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

product_fixes = {
    'prod_011': {'title': 'Bharat Cement PSC', 'name': 'Bharat Cement PSC', 'brand': 'bharat_cement'},
    'prod_012': {'title': 'OPC 53 Grade Cement', 'name': 'OPC 53 Grade Cement'},
    'prod_013': {'title': 'ACC Rapid-Setting Cement', 'name': 'ACC Rapid-Setting Cement', 'brand': 'acc'},
    'prod_014': {'title': 'Super Crete PPC Cement', 'name': 'Super Crete PPC Cement', 'brand': 'super_crete'},
    'prod_015': {'title': 'UltraTech Ready Mix Concrete', 'name': 'UltraTech Ready Mix Concrete', 'brand': 'ultratech'},
    'prod_016': {'title': 'Indian Construction Grout', 'name': 'Indian Construction Grout'},
    'prod_017': {'title': 'ACC Masonry Cement', 'name': 'ACC Masonry Cement', 'brand': 'acc'},
    'prod_018': {'title': 'UltraTech Tilefix', 'name': 'UltraTech Tilefix', 'brand': 'ultratech'},
    'prod_019': {'title': 'Birla White Wallcare Putty', 'name': 'Birla White Wallcare Putty', 'brand': 'birla_white'},
    'prod_020': {'title': 'UltraTech White Cement', 'name': 'UltraTech White Cement', 'brand': 'ultratech'},
}

for prod in data.get('products', []):
    if prod['id'] in product_fixes:
        fixes = product_fixes[prod['id']]
        prod['title'] = fixes.get('title', prod['title'])
        prod['name'] = fixes.get('name', prod['name'])
        if 'brand' in fixes:
            prod['brand'] = fixes['brand']

# Also add the missing brands to the brands array if they aren't there
existing_brands = {b['id'] for b in data.get('brands', [])}
new_brands = [
    {'id': 'bharat_cement', 'name': 'Bharat Cement', 'logoUrl': 'https://res.cloudinary.com/snwiu5gv/image/upload/v1738435200/buildmart_app/placeholder_logo.png'},
    {'id': 'acc', 'name': 'ACC', 'logoUrl': 'https://res.cloudinary.com/snwiu5gv/image/upload/v1738435200/buildmart_app/placeholder_logo.png'},
    {'id': 'super_crete', 'name': 'Super Crete', 'logoUrl': 'https://res.cloudinary.com/snwiu5gv/image/upload/v1738435200/buildmart_app/placeholder_logo.png'},
    {'id': 'birla_white', 'name': 'Birla White', 'logoUrl': 'https://res.cloudinary.com/snwiu5gv/image/upload/v1738435200/buildmart_app/placeholder_logo.png'}
]

for nb in new_brands:
    if nb['id'] not in existing_brands:
        data['brands'].append(nb)

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print("Products fixed successfully.")
