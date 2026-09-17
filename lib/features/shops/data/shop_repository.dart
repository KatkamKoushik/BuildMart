import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shop_model.dart';

class ShopRepository {
  final FirebaseFirestore _firestore;

  ShopRepository(this._firestore);

  Stream<List<ShopModel>> watchNearbyShops() {
    return _firestore
        .collection('shops')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ShopModel.fromJson(data);
      }).toList();
    });
  }
}

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(FirebaseFirestore.instance);
});

final nearbyShopsProvider = StreamProvider<List<ShopModel>>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.watchNearbyShops();
});
