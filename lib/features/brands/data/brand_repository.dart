import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/brand_model.dart';

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  return BrandRepository(FirebaseFirestore.instance);
});

final brandsProvider = StreamProvider<List<BrandModel>>((ref) {
  final repository = ref.watch(brandRepositoryProvider);
  return repository.watchBrands();
});

class BrandRepository {
  final FirebaseFirestore _firestore;

  BrandRepository(this._firestore);

  Stream<List<BrandModel>> watchBrands() {
    return _firestore.collection('brands').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['name'] = data['name'] ?? '';
        data['logoUrl'] = data['logoUrl'] ?? '';
        return BrandModel.fromJson(data);
      }).toList();
    });
  }
}
