import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/brand_model.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/local_catalog_service.dart';
import '../../../core/utils/brand_assets.dart';

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  return BrandRepository(FirebaseFirestore.instance);
});

final brandsProvider = StreamProvider<List<BrandModel>>((ref) {
  final repository = ref.watch(brandRepositoryProvider);
  return repository.watchBrands();
});

class BrandRepository {
  final FirebaseFirestore _firestore;
  final ApiClient _apiClient = ApiClient();

  BrandRepository(this._firestore);

  Stream<List<BrandModel>> watchBrands() async* {
    final localCatalog = LocalCatalogService.instance;
    await localCatalog.ensureInitialized();
    if (localCatalog.brands.isNotEmpty) {
      yield localCatalog.brands;
    }

    // Try backend API for brands
    try {
      final res = await _apiClient.get('/brands', auth: false);
      if (res is List && res.isNotEmpty) {
        final apiBrands = res.map((b) {
          final map = Map<String, dynamic>.from(b as Map);
          final id = map['id']?.toString() ?? '';
          final name = map['name']?.toString() ?? '';
          final rawLogo = map['image_url'] ?? map['imageUrl'] ?? map['logoUrl'];
          map['logoUrl'] =
              BrandAssets.resolveLogoUrl(id, rawLogo?.toString(), name);
          return BrandModel.fromJson(map);
        }).toList();
        yield apiBrands;
      }
    } catch (e) {
      debugPrint('[BrandRepository] Backend API brands notice: $e');
    }

    // Also stream from Firestore if available
    try {
      yield* _firestore.collection('brands').snapshots().map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            data['name'] = data['name'] ?? '';
            final rawLogo =
                data['logoUrl'] ?? data['image_url'] ?? data['imageUrl'];
            data['logoUrl'] = BrandAssets.resolveLogoUrl(
                doc.id, rawLogo?.toString(), data['name']);
            return BrandModel.fromJson(data);
          }).toList();
        }
        return localCatalog.brands;
      }).handleError((error) {
        debugPrint('[BrandRepository] Firestore fallback to local: $error');
        return localCatalog.brands;
      });
    } catch (e) {
      debugPrint('[BrandRepository] Firestore error: $e');
      if (localCatalog.brands.isNotEmpty) {
        yield localCatalog.brands;
      }
    }
  }
}
