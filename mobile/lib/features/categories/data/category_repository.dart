import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/category_model.dart';
import '../../../core/services/local_catalog_service.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(FirebaseFirestore.instance);
});

final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.watchCategories();
});

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository(this._firestore);

  Stream<List<CategoryModel>> watchCategories() async* {
    final localCatalog = LocalCatalogService.instance;
    await localCatalog.ensureInitialized();
    if (localCatalog.categories.isNotEmpty) {
      yield localCatalog.categories;
    }

    try {
      yield* _firestore.collection('categories').snapshots().map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            data['name'] = data['name'] ?? '';
            data['imageUrl'] = data['imageUrl'] ?? '';
            return CategoryModel.fromJson(data);
          }).toList();
        }
        return localCatalog.categories;
      }).handleError((error) {
        debugPrint('[CategoryRepository] Firestore fallback to local: $error');
        return localCatalog.categories;
      });
    } catch (e) {
      debugPrint('[CategoryRepository] Firestore error: $e');
      if (localCatalog.categories.isNotEmpty) {
        yield localCatalog.categories;
      }
    }
  }
}
