import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/category_model.dart';

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

  Stream<List<CategoryModel>> watchCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['name'] = data['name'] ?? '';
        data['imageUrl'] = data['imageUrl'] ?? '';
        return CategoryModel.fromJson(data);
      }).toList();
    });
  }
}
