import json

brands_data = [
    {"id": "acc", "name": "ACC Cement", "logoUrl": "assets/images/Brand Logos/ACC_brand_logo_card_design_202608071652.jpeg"},
    {"id": "asian_paints", "name": "Asian Paints", "logoUrl": "assets/images/Brand Logos/Asian_Paints_brand_logo_card_202608071652.jpeg"},
    {"id": "berger", "name": "Berger Paints", "logoUrl": "assets/images/Brand Logos/Berger_brand_logo_card_design_202608071652.jpeg"},
    {"id": "jaquar", "name": "Jaquar", "logoUrl": "assets/images/Brand Logos/Brand_logo_card_design_202608071652.jpeg"},
    {"id": "astral", "name": "Astral Pipes", "logoUrl": "assets/images/Brand Logos/Brand_logo_card_for_Astral_202608071652.jpeg"},
    {"id": "ramco", "name": "Ramco", "logoUrl": "assets/images/Brand Logos/Brand_logo_card_for_Ramco_202608071652.jpeg"},
    {"id": "priya", "name": "Priya Cement", "logoUrl": "assets/images/Brand Logos/Brand_logo_card_mockup_202608071652.jpeg"},
    {"id": "kcp", "name": "KCP Cement", "logoUrl": "assets/images/Brand Logos/KCP_brand_logo_card_mockup_202608071652.jpeg"},
    {"id": "penna", "name": "Penna Cement", "logoUrl": "assets/images/Brand Logos/Penna_brand_logo_card_mockup_202608071652.jpeg"},
    {"id": "supreme", "name": "Supreme Pipes", "logoUrl": "assets/images/Brand Logos/Supreme_Pipes_brand_logo_card_202608071652.jpeg"},
    {"id": "tata", "name": "Tata Steel", "logoUrl": "assets/images/Brand Logos/Tata_Steel_brand_logo_card_202608071652.jpeg"},
    {"id": "ultratech", "name": "UltraTech", "logoUrl": "assets/images/Brand Logos/UltraTech_brand_logo_card_202608071652.jpeg"}
]

with open('assets/seeded_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

data['brands'] = brands_data

with open('assets/seeded_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4)
