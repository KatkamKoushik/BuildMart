import json

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for p in data.get('products', []):
    price = p.get('price', 0)
    originalPrice = p.get('originalPrice', price)
    
    # Ensure all originalPrices that are > price are rounded to integer
    if originalPrice > price:
        p['originalPrice'] = round(originalPrice)
    else:
        # If no discount (originalPrice <= price), ensure originalPrice equals price to prevent null parsing errors in Dart
        p['originalPrice'] = price

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4)
print("Pricing data fixed.")
