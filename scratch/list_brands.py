import json

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for b in data.get('brands', []):
    print(f"{b['id']}: {b['name']} ({b['logoUrl']})")
