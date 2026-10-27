import cloudinary
import cloudinary.api

cloudinary.config(
  cloud_name = 'snwiu5gv',
  api_key = '969328414263883',
  api_secret = 'oLK_6m_Z6iTG78ZWK5CVcVtFAxI'
)

res = cloudinary.api.resources(type="upload", max_results=500, prefix="buildmart_app/")
for resource in res.get('resources', []):
    print(resource['secure_url'])
