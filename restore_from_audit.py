import json

with open('audit_output.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()

images = []
for line in lines[1:]: # Skip "--- PRODUCT IMAGES ---"
    line = line.strip()
    if line == '--- PRODUCT PRICING ---':
        break
    if ' | ' in line:
        name, img = line.split(' | ')
        images.append(img)

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for i, p in enumerate(data.get('products', [])):
    p['imageUrls'] = [images[i]]

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4)
print('Restored successfully from audit_output.txt')
