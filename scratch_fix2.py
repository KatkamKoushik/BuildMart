import json

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

new_products = []
for p in data['products']:
    # Remove the fallback doors glass which has a duplicated image
    if p.get('id') == 'prod_fallback_doors_glass':
        continue

    # Fix pricing
    price = p.get('price', 0)
    orig = p.get('originalPrice', 0)
    
    if orig <= price:
        if 'originalPrice' in p:
            del p['originalPrice']
            
    # Fix name:
    name = p.get('name', '')
    name = name.replace("Cpvc Plumbg Pipe", "CPVC Plumbing Pipe")
    name = name.replace("Grey Pvc Elbow Pipe Fitt", "Grey PVC Elbow Fitting")
    name = name.replace("Pvc", "PVC")
    name = name.replace("Cpvc", "CPVC")
    name = name.replace("Aac", "AAC")
    name = name.replace("Ggles", "Goggles")
    name = name.replace("Vrified", "Vitrified")
    name = name.replace("Reforcement", "Reinforcement")
    name = name.replace("Sgle", "Single")
    name = name.replace("Pe Wood", "Pine Wood")
    name = name.replace("Hdhmr", "HDHMR")
    name = name.replace("Fitt ", "Fitting ")
    if name.endswith("Fitt"):
        name = name[:-4] + "Fitting"
    p['name'] = name
    if 'title' in p:
        p['title'] = name
    
    # Description fixes (AI generated typos)
    desc = p.get('description', '')
    desc = desc.replace("Plumbg", "Plumbing")
    desc = desc.replace("Roofg", "Roofing")
    desc = desc.replace("Ggles", "Goggles")
    desc = desc.replace("Vrified", "Vitrified")
    desc = desc.replace("Reforcement", "Reinforcement")
    desc = desc.replace("Sgle", "Single")
    desc = desc.replace("Pe Wood", "Pine Wood")
    desc = desc.replace("Hdhmr", "HDHMR")
    desc = desc.replace("Tarpaul", "Tarpaulin")
    desc = desc.replace("Staless", "Stainless")
    p['description'] = desc

    new_products.append(p)

data['products'] = new_products

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4)

print("Done updating seeded_data.json completely.")
