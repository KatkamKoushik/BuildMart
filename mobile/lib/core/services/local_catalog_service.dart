import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/brand_model.dart';
import '../../models/category_model.dart';
import '../../features/shops/data/shop_model.dart';
import '../../features/products/data/product_model.dart';
import '../utils/brand_assets.dart';

final localCatalogServiceProvider = Provider<LocalCatalogService>((ref) {
  return LocalCatalogService.instance;
});

class LocalCatalogService extends ChangeNotifier {
  static final LocalCatalogService instance = LocalCatalogService._internal();
  LocalCatalogService._internal();

  bool _isInitialized = false;
  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];
  List<ProductModel> _products = [];
  List<String> _banners = [];
  List<ShopModel> _shops = [];

  bool get isInitialized => _isInitialized;
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<BrandModel> get brands => List.unmodifiable(_brands);
  List<ProductModel> get products => List.unmodifiable(_products);
  List<String> get banners => List.unmodifiable(_banners);
  List<ShopModel> get shops => List.unmodifiable(_shops);

  Map<String, dynamic> _mapProductData(Map<String, dynamic> raw, String id) {
    final data = Map<String, dynamic>.from(raw);
    data['id'] = id;
    data['title'] = data['title'] ?? data['name'] ?? '';
    data['brand'] = data['brand'] ?? '';
    data['imageUrl'] = data['imageUrl'] ??
        (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty
            ? data['imageUrls'][0]
            : '');
    data['reviews'] = data['reviews'] ?? data['totalReviews'] ?? 0;
    data['inStock'] = data['inStock'] ?? ((data['stockQuantity'] ?? 0) > 0);
    data['deliveryTime'] = data['deliveryTime'] ?? '2-3 days';
    data['price'] = (data['price'] ?? 0).toDouble();
    data['originalPrice'] = (data['originalPrice'] ?? 0).toDouble();
    data['rating'] = (data['rating'] ?? 0).toDouble();
    return data;
  }

  Future<void> ensureInitialized() async {
    if (_isInitialized && _products.isNotEmpty) return;
    await loadFromAssets();
  }

  Future<void> loadFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/seeded_data.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      // 1. Categories
      if (data['categories'] is List) {
        _categories = (data['categories'] as List).map((c) {
          final map = Map<String, dynamic>.from(c);
          return CategoryModel.fromJson(map);
        }).toList();
      }

      // 2. Brands with local offline logo resolution
      if (data['brands'] is List) {
        _brands = (data['brands'] as List).map((b) {
          final map = Map<String, dynamic>.from(b);
          final id = map['id']?.toString() ?? '';
          final name = map['name']?.toString() ?? '';
          map['logoUrl'] =
              BrandAssets.resolveLogoUrl(id, map['logoUrl']?.toString(), name);
          return BrandModel.fromJson(map);
        }).toList();
      }

      // 3. Products
      if (data['products'] is List) {
        _products = (data['products'] as List).map((p) {
          final raw = Map<String, dynamic>.from(p);
          final mapped = _mapProductData(raw, raw['id']?.toString() ?? '');
          return ProductModel.fromJson(mapped);
        }).toList();
      }

      // 4. Banners
      if (data['banners'] is List) {
        _banners = (data['banners'] as List).map((b) {
          if (b is Map && b['imageUrl'] != null) {
            return b['imageUrl'].toString();
          }
          return b.toString();
        }).toList();
      }

      // 5. Shops
      if (data['shops'] is List) {
        _shops = (data['shops'] as List).map((s) {
          final map = Map<String, dynamic>.from(s);
          map['id'] = map['id']?.toString() ?? 'shop_001';
          map['name'] = map['name'] ?? '';
          map['coverImageUrl'] = map['coverImageUrl'] ?? '';
          map['logoUrl'] = map['logoUrl'] ?? '';
          map['rating'] = (map['rating'] ?? 4.5).toDouble();
          map['reviewCount'] = (map['reviewCount'] ?? 50) is int
              ? map['reviewCount']
              : int.tryParse(map['reviewCount']?.toString() ?? '50') ?? 50;
          map['address'] = map['address'] ?? '';
          map['distance'] = map['distance']?.toString() ?? '1.5 km';
          map['isOpen'] = map['isOpen'] ?? true;
          map['categories'] = (map['categories'] is List)
              ? (map['categories'] as List).map((e) => e.toString()).toList()
              : <String>[];
          return ShopModel.fromJson(map);
        }).toList();
      }

      _isInitialized = true;
      notifyListeners();
      debugPrint(
          'LocalCatalogService: Successfully loaded ${_categories.length} categories, ${_brands.length} brands, ${_products.length} products, ${_banners.length} banners, and ${_shops.length} shops from seeded_data.json');
    } catch (e, stack) {
      debugPrint('LocalCatalogService initialization error: $e\n$stack');
    }
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProductModel> getProductsByCategory(String categoryId) {
    return _products.where((p) => true).toList();
  }

  List<ProductModel> getProductsByBrand(String brandId) {
    return _products
        .where((p) => p.brand.toLowerCase() == brandId.toLowerCase())
        .toList();
  }
}
