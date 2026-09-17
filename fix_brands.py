import json

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Remove duplicates and placeholders
brands_to_remove = {'tata', 'bharat_cement', 'super_crete', 'birla_white'}

# Filter brands
filtered_brands = [b for b in data.get('brands', []) if b['id'] not in brands_to_remove]
data['brands'] = filtered_brands

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)

print(f"Removed {len(brands_to_remove)} brands. New brand count: {len(filtered_brands)}")
