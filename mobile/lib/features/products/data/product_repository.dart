import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildmart/features/products/data/product_model.dart';
import '../../../core/services/local_catalog_service.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(FirebaseFirestore.instance);
});

final featuredProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchFeaturedProducts();
});

final productsByCategoryProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, categoryId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchProductsByCategory(categoryId);
});

final productsByBrandProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, brandId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchProductsByBrand(brandId);
});

final productStreamProvider =
    StreamProvider.family<ProductModel, String>((ref, id) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.watchProduct(id);
});

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository(this._firestore);

  Map<String, dynamic> _mapProductData(Map<String, dynamic> data, String id) {
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

  Stream<List<ProductModel>> watchFeaturedProducts() async* {
    final localCatalog = LocalCatalogService.instance;
    await localCatalog.ensureInitialized();
    if (localCatalog.products.isNotEmpty) {
      yield localCatalog.products;
    }

    try {
      yield* _firestore.collection('products').snapshots().map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            return ProductModel.fromJson(_mapProductData(doc.data(), doc.id));
          }).toList();
        }
        return localCatalog.products;
      }).handleError((error) {
        debugPrint('[ProductRepository] Firestore stream fallback to local: $error');
        return localCatalog.products;
      });
    } catch (e) {
      debugPrint('[ProductRepository] Firestore error: $e');
      if (localCatalog.products.isNotEmpty) {
        yield localCatalog.products;
      }
    }
  }

  Stream<List<ProductModel>> watchProductsByCategory(String categoryId) async* {
    final localCatalog = LocalCatalogService.instance;
    await localCatalog.ensureInitialized();
    final localCategoryProducts = localCatalog.getProductsByCategory(categoryId);
    if (localCategoryProducts.isNotEmpty) {
      yield localCategoryProducts;
    }

    try {
      yield* _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            return ProductModel.fromJson(_mapProductData(doc.data(), doc.id));
          }).toList();
        }
        return localCategoryProducts;
      }).handleError((error) {
        debugPrint('[ProductRepository] Firestore category fallback: $error');
        return localCategoryProducts;
      });
    } catch (e) {
      debugPrint('[ProductRepository] Firestore category error: $e');
      if (localCategoryProducts.isNotEmpty) {
        yield localCategoryProducts;
      }
    }
  }

  Stream<List<ProductModel>> watchProductsByBrand(String brandId) async* {
    final localCatalog = LocalCatalogService.instance;
    await localCatalog.ensureInitialized();
    final localBrandProducts = localCatalog.getProductsByBrand(brandId);
    if (localBrandProducts.isNotEmpty) {
      yield localBrandProducts;
    }

    try {
      yield* _firestore
          .collection('products')
          .where('brand', isEqualTo: brandId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            return ProductModel.fromJson(_mapProductData(doc.data(), doc.id));
          }).toList();
        }
        return localBrandProducts;
      }).handleError((error) {
        debugPrint('[ProductRepository] Firestore brand fallback: $error');
        return localBrandProducts;
      });
    } catch (e) {
      debugPrint('[ProductRepository] Firestore brand error: $e');
      if (localBrandProducts.isNotEmpty) {
        yield localBrandProducts;
      }
    }
  }

  Stream<ProductModel> watchProduct(String id) async* {
    final localCatalog = LocalCatalogService.instance;
    await localCatalog.ensureInitialized();
    final localProduct = localCatalog.getProductById(id);
    if (localProduct != null) {
      yield localProduct;
    }

    try {
      yield* _firestore.collection('products').doc(id).snapshots().map((doc) {
        if (doc.exists && doc.data() != null) {
          return ProductModel.fromJson(_mapProductData(doc.data()!, doc.id));
        }
        if (localProduct != null) return localProduct;
        throw Exception('Product not found in Firestore');
      }).handleError((error) {
        if (localProduct != null) return localProduct;
        throw Exception('Product not found: $error');
      });
    } catch (e) {
      if (localProduct != null) {
        yield localProduct;
      } else {
        throw Exception('Product not found');
      }
    }
  }
}
