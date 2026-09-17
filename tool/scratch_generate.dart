import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:path/path.dart' as p;

void main() async {
  final rootDir = Directory('assets/images/product images');
  if (!rootDir.existsSync()) {
    print('Error: Directory not found: ${rootDir.path}');
    return;
  }

  List<Map<String, dynamic>> products = [];
  final random = Random();
  int idCounter = 1;
  
  List<String> removalWords = [
    'product', 'photography', 'catalog', 'on display', 'on white background', 
    'sample', 'phot', 'laid flat', 'view', 'heap of', 'pile of', 'box of', 
    'tub of', 'tin can of', 'bag of', 'in', 'shown', 'arrangement', 'displayed', 
    'front', 'background', 'photo', 'with keys', 'flat and', 'cut edge', 'stack of',
    'photo..', 'phot...', 'photog...', 'photogra...', 'photograp...', 'studio', 'og'
  ];

  String cleanTitle(String filename) {
    String name = p.basenameWithoutExtension(filename);
    
    // Remove numbers and timestamps (like 202608071650)
    name = name.replaceAll(RegExp(r'\d{10,}'), '');
    
    // Replace underscores and dashes
    name = name.replaceAll('_', ' ').replaceAll('-', ' ');
    
    // Remove non-ascii characters
    name = name.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');
    
    name = name.toLowerCase();
    
    // Remove specific words
    for (var word in removalWords) {
      name = name.replaceAll(word, '');
    }
    
    // Remove any trailing or multiple spaces
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Title Case
    if (name.isEmpty) return 'Building Material';
    return name.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }

  String mapCategory(String folderName) {
    folderName = folderName.toLowerCase();
    if (folderName.contains('brick') || folderName.contains('block')) return 'bricks_blocks';
    if (folderName.contains('electrical')) return 'electricals';
    if (folderName.contains('hardware') || folderName.contains('tool')) return 'hardware_tools';
    if (folderName.contains('paint') || folderName.contains('waterproof')) {
      if (random.nextBool()) return 'paints';
      return 'waterproofing';
    }
    if (folderName.contains('plumb')) return 'plumbing';
    if (folderName.contains('roof') || folderName.contains('site')) {
      if (random.nextBool()) return 'roofing';
      return 'site_materials';
    }
    if (folderName.contains('safety')) return 'safety_equipment';
    if (folderName.contains('sand') || folderName.contains('aggregate')) return 'sand_aggregates';
    if (folderName.contains('tile') || folderName.contains('stone')) return 'tiles_stone';
    if (folderName.contains('wood') || folderName.contains('board')) return 'wood_boards';
    if (folderName.contains('cement')) return 'cement';
    if (folderName.contains('steel')) {
      if (random.nextBool()) return 'steel';
      return 'fasteners';
    }
    return 'site_materials';
  }

  await for (var entity in rootDir.list(recursive: true)) {
    if (entity is File) {
      final ext = p.extension(entity.path).toLowerCase();
      if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
        final folderName = p.basename(entity.parent.path);
        final title = cleanTitle(p.basename(entity.path));
        final categoryId = mapCategory(folderName);
        
        // Random price between 50 and 5000
        final price = 50.0 + random.nextInt(4950);
        final hasDiscount = random.nextBool();
        final originalPrice = hasDiscount ? price * (1.1 + random.nextDouble() * 0.4) : price;
        
        // Assign a random brand from available brands
        final brandId = ['tata_tiscon', 'ultratech', 'asian_paints', 'jaquar'][random.nextInt(4)];

        products.add({
          "id": "prod_${idCounter.toString().padLeft(3, '0')}",
          "name": title.isEmpty ? "Building Material" : title,
          "description": "High-quality $title for your construction and building needs. Manufactured to meet industry standards.",
          "price": double.parse(price.toStringAsFixed(2)),
          "originalPrice": double.parse(originalPrice.toStringAsFixed(2)),
          "brand": brandId,
          "categoryId": categoryId,
          "shopId": "shop_01",
          "imageUrls": [
            entity.path.replaceAll('\\', '/')
          ],
          "specifications": {
            "Material": "Standard",
            "Unit": "Piece/Bag"
          },
          "rating": double.parse((3.5 + random.nextDouble() * 1.5).toStringAsFixed(1)),
          "totalReviews": random.nextInt(500),
          "stockQuantity": random.nextInt(200) + 10
        });
        idCounter++;
      }
    }
  }

  // To make sure all categories have at least 1 product, let's inject a dummy if any is empty (unlikely with 150 images, but just in case)
  final allCategories = [
    'cement', 'steel', 'bricks_blocks', 'sand_aggregates', 'plumbing', 
    'electricals', 'paints', 'tiles_stone', 'hardware_tools', 'roofing', 
    'wood_boards', 'safety_equipment', 'waterproofing', 'site_materials', 
    'doors_glass', 'fasteners'
  ];
  
  for (var cat in allCategories) {
    if (!products.any((p) => p['categoryId'] == cat)) {
       products.add({
          "id": "prod_fallback_$cat",
          "name": "Standard ${cat.replaceAll('_', ' ').toUpperCase()}",
          "description": "Standard item for category",
          "price": 100.0,
          "originalPrice": 120.0,
          "brand": "tata_tiscon",
          "categoryId": cat,
          "shopId": "shop_01",
          "imageUrls": [
            "assets/images/Empty State Illustrations/Empty_delivery_box_illustration_202608071708.jpeg"
          ],
          "specifications": {},
          "rating": 4.5,
          "totalReviews": 10,
          "stockQuantity": 50
        });
    }
  }

  final categories = [
    {"id": "cement", "name": "Cement"},
    {"id": "steel", "name": "Steel"},
    {"id": "bricks_blocks", "name": "Bricks & Blocks"},
    {"id": "sand_aggregates", "name": "Sand & Aggregates"},
    {"id": "plumbing", "name": "Plumbing"},
    {"id": "electricals", "name": "Electricals"},
    {"id": "paints", "name": "Paints"},
    {"id": "tiles_stone", "name": "Tiles & Stone"},
    {"id": "hardware_tools", "name": "Hardware & Tools"},
    {"id": "roofing", "name": "Roofing"},
    {"id": "wood_boards", "name": "Wood & Boards"},
    {"id": "safety_equipment", "name": "Safety Equipment"},
    {"id": "waterproofing", "name": "Waterproofing"},
    {"id": "site_materials", "name": "Site Materials"},
    {"id": "doors_glass", "name": "Doors & Glass"},
    {"id": "fasteners", "name": "Fasteners"}
  ];

  final brands = [
    {
      "id": "tata_tiscon",
      "name": "Tata Tiscon",
      "logoUrl": "https://via.placeholder.com/150",
      "description": "Premium TMT Bars"
    },
    {
      "id": "ultratech",
      "name": "UltraTech",
      "logoUrl": "https://via.placeholder.com/150",
      "description": "The Engineer's Choice"
    },
    {
      "id": "asian_paints",
      "name": "Asian Paints",
      "logoUrl": "https://via.placeholder.com/150",
      "description": "Beautiful Homes"
    },
    {
      "id": "jaquar",
      "name": "Jaquar",
      "logoUrl": "https://via.placeholder.com/150",
      "description": "Complete Bathroom Solutions"
    }
  ];

  final banners = [
    {
      "id": "banner_1",
      "title": "Summer Sale",
      "subtitle": "Up to 30% off on Plumbing",
      "imageUrl": "assets/images/BuildMart Home Banners/BuildMart_promo_banner_tools_202608071708.jpeg",
      "targetUrl": "/category/plumbing"
    },
    {
      "id": "banner_2",
      "title": "New Arrivals",
      "subtitle": "Latest in Premium Tiles",
      "imageUrl": "assets/images/BuildMart Home Banners/BuildMart_sale_banner_yellow_202608071708.jpeg",
      "targetUrl": "/category/tiles_stone"
    },
    {
      "id": "banner_3",
      "title": "Bulk Discount",
      "subtitle": "Special rates for Cement",
      "imageUrl": "assets/images/BuildMart Home Banners/BuildMart_wide_banner_materials_202608071708.jpeg",
      "targetUrl": "/category/cement"
    }
  ];

  final data = {
    "categories": categories,
    "products": products,
    "brands": brands,
    "banners": banners
  };

  final file = File('assets/seeded_data.json');
  await file.writeAsString(jsonEncode(data));
  print('Successfully generated seeded_data.json with ${products.length} products.');
}
