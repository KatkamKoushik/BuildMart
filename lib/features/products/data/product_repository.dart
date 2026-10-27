import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildmart/features/products/data/product_model.dart';

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
    data['brand'] = data['brand'] ?? ''; // Handle missing brand
    data['imageUrl'] = data['imageUrl'] ??
        (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty
            ? data['imageUrls'][0]
            : '');
    data['reviews'] = data['reviews'] ?? data['totalReviews'] ?? 0;
    data['inStock'] = data['inStock'] ?? ((data['stockQuantity'] ?? 0) > 0);
    data['deliveryTime'] = data['deliveryTime'] ?? '2-3 days';

    // Ensure numeric types match the model
    data['price'] = (data['price'] ?? 0).toDouble();
    data['originalPrice'] = (data['originalPrice'] ?? 0).toDouble();
    data['rating'] = (data['rating'] ?? 0).toDouble();

    return data;
  }

  Stream<List<ProductModel>> watchFeaturedProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromJson(_mapProductData(doc.data(), doc.id));
      }).toList();
    });
  }

  Stream<List<ProductModel>> watchProductsByCategory(String categoryId) {
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromJson(_mapProductData(doc.data(), doc.id));
      }).toList();
    });
  }

  Stream<List<ProductModel>> watchProductsByBrand(String brandId) {
    return _firestore
        .collection('products')
        .where('brand', isEqualTo: brandId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromJson(_mapProductData(doc.data(), doc.id));
      }).toList();
    });
  }

  Stream<ProductModel> watchProduct(String id) {
    return _firestore.collection('products').doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('Product not found in Firestore');
      }
      return ProductModel.fromJson(_mapProductData(doc.data()!, doc.id));
    });
  }
}
