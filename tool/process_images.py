import os
import re
import json
import shutil

# Directories
ASSETS_DIR = os.path.join("assets", "images")
SEEDED_DATA_PATH = os.path.join("assets", "seeded_data.json")
NETWORK_IMAGE_WIDGET_PATH = os.path.join("lib", "shared", "widgets", "network_image_widget.dart")
PUBSPEC_PATH = "pubspec.yaml"

def clean_filename(filename):
    name, ext = os.path.splitext(filename)
    # Remove timestamps like _202608071708
    name = re.sub(r'_\d{10,}', '', name)
    # Remove "ChatGPT Image" or similar
    name = re.sub(r'(?i)chatgpt image.*', 'banner', name)
    # Replace spaces and special characters with underscore
    name = re.sub(r'[^a-zA-Z0-9]', '_', name)
    # Remove consecutive underscores
    name = re.sub(r'_+', '_', name)
    # Lowercase
    name = name.strip('_').lower()
    
    return name, ext.lower()

def clean_directory_name(dirname):
    name = re.sub(r'[^a-zA-Z0-9]', '_', dirname)
    name = re.sub(r'_+', '_', name)
    return name.strip('_').lower()

def main():
    if not os.path.exists(ASSETS_DIR):
        print(f"Error: {ASSETS_DIR} not found.")
        return

    print("Starting image processing...")

    with open(SEEDED_DATA_PATH, 'r', encoding='utf-8') as f:
        seeded_data = json.load(f)
    with open(NETWORK_IMAGE_WIDGET_PATH, 'r', encoding='utf-8') as f:
        network_widget_code = f.read()
    with open(PUBSPEC_PATH, 'r', encoding='utf-8') as f:
        pubspec_content = f.read()

    rename_map = {}
    banner_count = 1

    # Traverse directory and rename
    for root, dirs, files in os.walk(ASSETS_DIR, topdown=False):
        # To avoid collisions
        seen_names = set()
        
        for filename in files:
            old_filepath = os.path.join(root, filename)
            old_rel_path = old_filepath.replace("\\", "/")

            base_name, ext = clean_filename(filename)
            
            if base_name.startswith('banner'):
                new_filename = f"banner_{banner_count}{ext}"
                banner_count += 1
            else:
                # Handle collision
                new_filename = f"{base_name}{ext}"
                counter = 1
                while new_filename in seen_names or os.path.exists(os.path.join(root, new_filename)):
                    if old_filepath == os.path.join(root, new_filename):
                        break # It's the same file
                    new_filename = f"{base_name}_{counter}{ext}"
                    counter += 1
            
            seen_names.add(new_filename)
            new_filepath = os.path.join(root, new_filename)
            new_rel_path = new_filepath.replace("\\", "/")

            if old_filepath != new_filepath:
                try:
                    os.rename(old_filepath, new_filepath)
                    rename_map[old_rel_path] = new_rel_path
                    print(f"Renamed file: {old_rel_path} -> {new_rel_path}")
                except Exception as e:
                    print(f"Error renaming {old_filepath} to {new_filepath}: {e}")

        for dirname in dirs:
            old_dirpath = os.path.join(root, dirname)
            old_rel_dirpath = old_dirpath.replace("\\", "/") + "/"
            
            new_dirname = clean_directory_name(dirname)
            new_dirpath = os.path.join(root, new_dirname)
            new_rel_dirpath = new_dirpath.replace("\\", "/") + "/"

            if old_dirpath != new_dirpath:
                try:
                    os.rename(old_dirpath, new_dirpath)
                    new_rename_map = {}
                    for old_p, new_p in rename_map.items():
                        updated_old = old_p.replace(old_rel_dirpath, new_rel_dirpath)
                        updated_new = new_p.replace(old_rel_dirpath, new_rel_dirpath)
                        new_rename_map[updated_old] = updated_new
                    
                    for old_p, new_p in rename_map.items():
                        updated_new = new_p.replace(old_rel_dirpath, new_rel_dirpath)
                        new_rename_map[old_p] = updated_new

                    rename_map.update(new_rename_map)
                    pubspec_content = pubspec_content.replace(old_rel_dirpath, new_rel_dirpath)
                    print(f"Renamed directory: {old_rel_dirpath} -> {new_rel_dirpath}")
                except Exception as e:
                    print(f"Error renaming dir {old_dirpath} to {new_dirpath}: {e}")

    # Process seeded_data.json
    def update_json_urls(data):
        if isinstance(data, dict):
            for k, v in data.items():
                if k in ['imageUrl', 'imageUrls'] and isinstance(v, str):
                    if v in rename_map:
                        data[k] = rename_map[v]
                elif k == 'imageUrls' and isinstance(v, list):
                    data[k] = [rename_map.get(url, url) for url in v]
                else:
                    update_json_urls(v)
        elif isinstance(data, list):
            for item in data:
                update_json_urls(item)

    update_json_urls(seeded_data)
    with open(SEEDED_DATA_PATH, 'w', encoding='utf-8') as f:
        json.dump(seeded_data, f, indent=4)
    print("Updated seeded_data.json with local renamed paths.")

    # Process network_image_widget.dart
    for old_p, new_p in rename_map.items():
        if old_p in network_widget_code:
            network_widget_code = network_widget_code.replace(old_p, new_p)
    with open(NETWORK_IMAGE_WIDGET_PATH, 'w', encoding='utf-8') as f:
        f.write(network_widget_code)
    print("Updated network_image_widget.dart.")

    # Process pubspec.yaml
    with open(PUBSPEC_PATH, 'w', encoding='utf-8') as f:
        f.write(pubspec_content)
    print("Updated pubspec.yaml.")

    print("\nLocal renaming completed successfully.")

if __name__ == "__main__":
    main()
