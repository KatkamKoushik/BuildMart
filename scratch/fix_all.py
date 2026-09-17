import json, os, shutil
import uuid

def clean_filename(filename):
    # Remove weird characters like , …, etc.
    name, ext = os.path.splitext(filename)
    clean_name = name.replace('\ufffd', '_').replace('\u2026', '_').replace('...', '_')
    return clean_name + ext

dirs_to_clean = [
    'assets/images/home screen category grid',
    'assets/images/product images',
    'assets/images/Brand Logos'
]

# 1. Rename files on disk
renames_map = {}
for d in dirs_to_clean:
    for root, _, files in os.walk(d):
        for f in files:
            clean_f = clean_filename(f)
            if clean_f != f:
                old_path = os.path.join(root, f)
                new_path = os.path.join(root, clean_f)
                os.rename(old_path, new_path)
                
                # store normalized paths for mapping
                old_rel = old_path.replace('\\', '/')
                new_rel = new_path.replace('\\', '/')
                renames_map[old_rel] = new_rel

# 2. Update seeded_data.json
with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Banners (ensure 8 banners)
banner_dir = 'assets/images/BuildMart Home Banners'
banner_files = [f for f in os.listdir(banner_dir) if f.endswith('.png') or f.endswith('.jpeg')]
banner_files.sort()
if 'banners' not in data: data['banners'] = []
current_banners = data['banners']
# we have 3 banners, we want to match len(banner_files)
while len(current_banners) < len(banner_files):
    new_banner = dict(current_banners[0]) # copy first
    new_banner['id'] = f"banner_{len(current_banners) + 1}"
    current_banners.append(new_banner)
for i, banner in enumerate(current_banners):
    banner['imageUrl'] = f"{banner_dir}/{banner_files[i]}"

# Products
for p in data.get('products', []):
    if p.get('imageUrls'):
        url = p['imageUrls'][0]
        # check if it was renamed
        if url in renames_map:
            p['imageUrls'][0] = renames_map[url]
        else:
            # fallback door image fix
            if 'Empty State Illustrations' in url:
                # pick a valid door image
                p['imageUrls'][0] = 'assets/images/product images/Wood & Boards/Wooden_flush_door_studio_view_202608091631.jpeg'

# Categories
for c in data.get('categories', []):
    if c.get('imageUrl'):
        url = c['imageUrl']
        # check if we can fix the url to match exactly what is on disk
        folder = os.path.dirname(url)
        if os.path.exists(folder):
            real_files = os.listdir(folder)
            basename = os.path.basename(url)
            # if basename has . we used in previous fix, match by prefix
            prefix = basename.split('.')[0]
            if len(prefix) > 15: prefix = prefix[:15]
            
            matches = [f for f in real_files if f.startswith(prefix)]
            if matches:
                c['imageUrl'] = f"{folder}/{matches[0]}"
            else:
                c['imageUrl'] = f"{folder}/{real_files[0]}"

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, separators=(',', ':'))

print('Fixed files on disk and updated seeded_data.json')
