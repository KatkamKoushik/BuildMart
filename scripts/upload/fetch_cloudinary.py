import cloudinary
import cloudinary.api

import os

cloudinary.config(
  cloud_name = os.getenv('CLOUDINARY_CLOUD_NAME', 'snwiu5gv'),
  api_key = os.getenv('CLOUDINARY_API_KEY', ''),
  api_secret = os.getenv('CLOUDINARY_API_SECRET', '')
)

res = cloudinary.api.resources(type="upload", max_results=500, prefix="buildmart_app/")
for resource in res.get('resources', []):
    print(resource['secure_url'])
