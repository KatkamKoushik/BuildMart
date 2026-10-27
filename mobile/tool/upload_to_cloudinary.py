import os
import json
import shutil
import cloudinary
import cloudinary.uploader
from dotenv import load_dotenv

load_dotenv()

# Check Cloudinary Credentials
cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME")
api_key = os.getenv("CLOUDINARY_API_KEY")
api_secret = os.getenv("CLOUDINARY_API_SECRET")

if not cloud_name or not api_key or not api_secret:
    print("Error: Cloudinary credentials not found in .env file.")
    print("Please fill in CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET.")
    exit(1)

cloudinary.config(
    cloud_name=cloud_name,
    api_key=api_key,
    api_secret=api_secret
)

SEEDED_DATA_PATH = os.path.join("assets", "seeded_data.json")

ONLINE_DIRS = [
    os.path.join("assets", "images", "brand_logos"),
    os.path.join("assets", "images", "buildmart_home_banners"),
    os.path.join("assets", "images", "home_screen_category_grid"),
    os.path.join("assets", "images", "product_images")
]

def main():
    print("Starting Cloudinary Upload Process...")
    
    with open(SEEDED_DATA_PATH, 'r', encoding='utf-8') as f:
        seeded_data = json.load(f)

    upload_map = {}

    for directory in ONLINE_DIRS:
        if not os.path.exists(directory):
            print(f"Skipping {directory}, not found.")
            continue
            
        for root, dirs, files in os.walk(directory):
            for filename in files:
                local_path = os.path.join(root, filename)
                local_rel_path = local_path.replace("\\", "/")
                
                print(f"Uploading {local_rel_path}...")
                try:
                    # Upload to cloudinary in a 'buildmart' folder to keep it organized
                    response = cloudinary.uploader.upload(
                        local_path,
                        folder="buildmart_app"
                    )
                    secure_url = response.get('secure_url')
                    if secure_url:
                        upload_map[local_rel_path] = secure_url
                        print(f"Success: {secure_url}")
                except Exception as e:
                    print(f"Failed to upload {local_rel_path}: {e}")

    # Process seeded_data.json
    def update_json_urls(data):
        if isinstance(data, dict):
            for k, v in data.items():
                if k in ['imageUrl', 'imageUrls'] and isinstance(v, str):
                    if v in upload_map:
                        data[k] = upload_map[v]
                elif k == 'imageUrls' and isinstance(v, list):
                    data[k] = [upload_map.get(url, url) for url in v]
                else:
                    update_json_urls(v)
        elif isinstance(data, list):
            for item in data:
                update_json_urls(item)

    if upload_map:
        update_json_urls(seeded_data)
        with open(SEEDED_DATA_PATH, 'w', encoding='utf-8') as f:
            json.dump(seeded_data, f, indent=4)
        print("Updated seeded_data.json with Cloudinary URLs.")
        
        # Cleanup online directories since they are now in the cloud
        for directory in ONLINE_DIRS:
            if os.path.exists(directory):
                try:
                    shutil.rmtree(directory)
                    print(f"Deleted local directory: {directory}")
                except Exception as e:
                    print(f"Failed to delete {directory}: {e}")
    else:
        print("No images were uploaded.")

    print("\nUpload process completed.")

if __name__ == "__main__":
    main()
