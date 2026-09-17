import json, os

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

cat_images_dir = 'assets/images/home screen category grid'
cat_images = os.listdir(cat_images_dir)

print('Categories mapping check:')
for c in data.get('categories', []):
    img = c.get('imageUrl', '')
    if img:
        img_name = os.path.basename(img)
        if img_name not in cat_images:
            print(f"  {c['name']}: {img_name} (Missing on disk)")
        else:
            print(f"  {c['name']}: {img_name} (OK)")
    else:
        print(f"  {c['name']}: No imageUrl defined")
