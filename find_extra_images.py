import json
import cloudinary
import cloudinary.api

cloudinary.config(
  cloud_name = 'snwiu5gv',
  api_key = '969328414263883',
  api_secret = 'oLK_6m_Z6iTG78ZWK5CVcVtFAxI'
)

# 1. Get all URLs from JSON
with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

json_urls = set()
for p in data.get('products', []):
    json_urls.update(p.get('imageUrls', []))
for b in data.get('brands', []):
    if 'logoUrl' in b:
        json_urls.add(b['logoUrl'])
for ban in data.get('banners', []):
    if 'imageUrl' in ban:
        json_urls.add(ban['imageUrl'])

# 2. Get all URLs from Cloudinary
res = cloudinary.api.resources(type="upload", max_results=500, prefix="buildmart_app/")
cloud_urls = set(r['secure_url'] for r in res.get('resources', []))

# 3. Find the extra images
extra_images = cloud_urls - json_urls

print(f"Total in JSON: {len(json_urls)}")
print(f"Total in Cloudinary: {len(cloud_urls)}")
print(f"Extra Images ({len(extra_images)}):")
for url in sorted(extra_images):
    print(url)
