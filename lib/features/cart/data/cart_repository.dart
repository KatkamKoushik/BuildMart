import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildmart/features/cart/data/cart_item_model.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(FirebaseFirestore.instance);
});

final cartStreamProvider = StreamProvider.family<List<CartItemModel>, String>((ref, userId) {
  final repository = ref.watch(cartRepositoryProvider);
  return repository.watchCart(userId);
});

class CartRepository {
  final FirebaseFirestore _firestore;

  CartRepository(this._firestore);

  Stream<List<CartItemModel>> watchCart(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CartItemModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> updateQuantity(String userId, String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(itemId)
          .delete();
    } else {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(itemId)
          .update({'quantity': newQuantity});
    }
  }

  Future<void> addToCart(String userId, CartItemModel item) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(item.id);
        
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.update({'quantity': FieldValue.increment(item.quantity)});
    } else {
      await docRef.set(item.toJson());
    }
  }
}
