import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shop_model.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/local_catalog_service.dart';

class ShopRepository {
  final FirebaseFirestore _firestore;
  final ApiClient _apiClient = ApiClient();

  ShopRepository(this._firestore);

  ShopModel _mapBackendShop(Map<String, dynamic> data) {
    final id = data['id']?.toString() ?? 'shop_001';
    return ShopModel(
      id: id,
      name: data['name']?.toString() ?? '',
      coverImageUrl: data['cover_image_url']?.toString() ?? data['coverImageUrl']?.toString() ?? '',
      logoUrl: data['logo_url']?.toString() ?? data['logoUrl']?.toString() ?? '',
      rating: (data['rating'] ?? 4.5).toDouble(),
      reviewCount: (data['review_count'] ?? data['reviewCount'] ?? 0) is int
          ? (data['review_count'] ?? data['reviewCount'] ?? 0)
          : int.tryParse(data['review_count']?.toString() ?? '0') ?? 0,
      address: data['address']?.toString() ?? '',
      distance: data['distance_km'] != null ? '${data['distance_km']} km' : (data['distance']?.toString() ?? '1.5 km'),
      isOpen: data['is_open'] ?? data['isOpen'] ?? true,
      categories: (data['categories'] is List)
          ? (data['categories'] as List).map((e) => e.toString()).toList()
          : <String>[],
    );
  }

  Stream<List<ShopModel>> watchNearbyShops() async* {
    final localCatalog = LocalCatalogService.instance;
    await localCatalog.ensureInitialized();
    if (localCatalog.shops.isNotEmpty) {
      yield localCatalog.shops;
    }

    // 1. Try Backend API for real shops
    try {
      final res = await _apiClient.get('/shops', auth: false);
      if (res is List && res.isNotEmpty) {
        final apiShops = res
            .map((item) => _mapBackendShop(Map<String, dynamic>.from(item as Map)))
            .toList();
        yield apiShops;
      }
    } catch (e) {
      debugPrint('[ShopRepository] Backend API shops notice: $e');
    }

    // 2. Stream from Firestore
    try {
      yield* _firestore.collection('shops').snapshots().map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return _mapBackendShop(data);
          }).toList();
        }
        return localCatalog.shops;
      }).handleError((error) {
        debugPrint('[ShopRepository] Firestore shops error: $error');
        return localCatalog.shops;
      });
    } catch (e) {
      debugPrint('[ShopRepository] Firestore error: $e');
      if (localCatalog.shops.isNotEmpty) {
        yield localCatalog.shops;
      }
    }
  }

  Stream<ShopModel?> watchShop(String id) async* {
    final localCatalog = LocalCatalogService.instance;
    await localCatalog.ensureInitialized();
    final localMatch = localCatalog.shops.where((s) => s.id == id).toList();
    if (localMatch.isNotEmpty) {
      yield localMatch.first;
    }

    try {
      final res = await _apiClient.get('/shops/$id', auth: false);
      if (res is Map<String, dynamic>) {
        yield _mapBackendShop(res);
      }
    } catch (_) {}

    try {
      yield* _firestore.collection('shops').doc(id).snapshots().map((doc) {
        if (doc.exists && doc.data() != null) {
          final data = Map<String, dynamic>.from(doc.data()!);
          data['id'] = doc.id;
          return _mapBackendShop(data);
        }
        return localMatch.isNotEmpty ? localMatch.first : null;
      });
    } catch (_) {
      if (localMatch.isNotEmpty) {
        yield localMatch.first;
      }
    }
  }
}

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(FirebaseFirestore.instance);
});

final nearbyShopsProvider = StreamProvider<List<ShopModel>>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.watchNearbyShops();
});

final shopByIdProvider = StreamProvider.family<ShopModel?, String>((ref, shopId) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.watchShop(shopId);
});
