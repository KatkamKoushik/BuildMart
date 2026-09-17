import os
import re
import json

LOG_PATH = r"C:\Users\pidug\.gemini\antigravity-ide\brain\a666c324-d967-43c1-95a4-cb5227327c61\.system_generated\tasks\task-210.log"
SEEDED_DATA_PATH = os.path.join("assets", "seeded_data.json")

def clean_filename(filename):
    name, ext = os.path.splitext(filename)
    name = re.sub(r'_\d{10,}', '', name)
    name = re.sub(r'(?i)chatgpt image.*', 'banner', name)
    name = re.sub(r'[^a-zA-Z0-9]', '_', name)
    name = re.sub(r'_+', '_', name)
    name = name.strip('_').lower()
    return f"{name}{ext.lower()}"

def clean_directory_name(dirname):
    name = re.sub(r'[^a-zA-Z0-9]', '_', dirname)
    name = re.sub(r'_+', '_', name)
    return name.strip('_').lower()

def clean_path(path):
    parts = path.split('/')
    if len(parts) > 1:
        # Clean directories (except 'assets' and 'images' which are already clean)
        cleaned_parts = [clean_directory_name(p) if i > 1 and i < len(parts)-1 else p for i, p in enumerate(parts)]
        cleaned_parts[-1] = clean_filename(cleaned_parts[-1])
        return '/'.join(cleaned_parts)
    return path

def main():
    if not os.path.exists(LOG_PATH):
        print(f"Error: Log file not found at {LOG_PATH}")
        return

    # 1. Parse log file
    upload_map = {}
    current_upload = None
    with open(LOG_PATH, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line.startswith("Uploading "):
                current_upload = line.replace("Uploading ", "").replace("...", "")
            elif line.startswith("Success: "):
                url = line.replace("Success: ", "")
                if current_upload:
                    upload_map[current_upload] = url
                    current_upload = None

    print(f"Parsed {len(upload_map)} mappings from log file.")

    # 2. Process seeded_data.json
    with open(SEEDED_DATA_PATH, 'r', encoding='utf-8') as f:
        seeded_data = json.load(f)

    updates_made = 0
    banner_counter = 1

    def process_url(url):
        nonlocal updates_made
        nonlocal banner_counter
        
        if url.startswith('http'):
            return url
            
        if 'empty_state' in url.lower() or 'Empty State' in url:
            return clean_path(url)
            
        cleaned = clean_path(url)
        
        if 'banner.png' in cleaned:
            # sequentially assign banner_1, banner_2, etc.
            banner_key = f"assets/images/buildmart_home_banners/banner_{banner_counter}.png"
            banner_counter += 1
            if banner_key in upload_map:
                updates_made += 1
                return upload_map[banner_key]

        if cleaned in upload_map:
            updates_made += 1
            return upload_map[cleaned]
            
        for k, v in upload_map.items():
            if cleaned.split('/')[-1] in k:
                updates_made += 1
                return v

        print(f"Warning: Could not find mapping for {url} (cleaned: {cleaned})")
        return cleaned

    def update_json_urls(data):
        if isinstance(data, dict):
            for k, v in data.items():
                if k in ['imageUrl', 'imageUrls', 'logoUrl'] and isinstance(v, str):
                    data[k] = process_url(v)
                elif k == 'imageUrls' and isinstance(v, list):
                    data[k] = [process_url(url) for url in v]
                else:
                    update_json_urls(v)
        elif isinstance(data, list):
            for item in data:
                update_json_urls(item)

    update_json_urls(seeded_data)
    
    with open(SEEDED_DATA_PATH, 'w', encoding='utf-8') as f:
        json.dump(seeded_data, f, indent=4)
        
    print(f"Successfully updated {updates_made} URLs in seeded_data.json")

if __name__ == "__main__":
    main()
