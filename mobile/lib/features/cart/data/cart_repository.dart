import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buildmart/features/cart/data/cart_item_model.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(FirebaseFirestore.instance);
});

final cartStreamProvider =
    StreamProvider.family<List<CartItemModel>, String>((ref, userId) {
  final repository = ref.watch(cartRepositoryProvider);
  return repository.watchCart(userId);
});

class CartRepository {
  final FirebaseFirestore _firestore;
  final Map<String, List<CartItemModel>> _memoryCart = {};
  final Map<String, StreamController<List<CartItemModel>>> _controllers = {};

  CartRepository(this._firestore);

  StreamController<List<CartItemModel>> _getController(String userId) {
    return _controllers.putIfAbsent(
      userId,
      () => StreamController<List<CartItemModel>>.broadcast(),
    );
  }

  Future<List<CartItemModel>> _loadLocalCart(String userId) async {
    if (_memoryCart.containsKey(userId)) {
      return List<CartItemModel>.from(_memoryCart[userId]!);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList('cart_items_$userId') ?? [];
      final items = jsonList.map((str) {
        try {
          final map = jsonDecode(str) as Map<String, dynamic>;
          return CartItemModel.fromJson(map);
        } catch (_) {
          return null;
        }
      }).whereType<CartItemModel>().toList();
      _memoryCart[userId] = items;
      return items;
    } catch (e) {
      debugPrint('[CartRepository] Failed to read local cart: $e');
      return [];
    }
  }

  Future<void> _saveLocalCart(String userId, List<CartItemModel> items) async {
    _memoryCart[userId] = List<CartItemModel>.from(items);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('cart_items_$userId', jsonList);
    } catch (e) {
      debugPrint('[CartRepository] Failed to save local cart: $e');
    }
    _getController(userId).add(List<CartItemModel>.unmodifiable(items));
  }

  Stream<List<CartItemModel>> watchCart(String userId) async* {
    final localItems = await _loadLocalCart(userId);
    yield localItems;

    final controller = _getController(userId);

    // Try listening to Firestore if available
    try {
      _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .snapshots()
          .listen((snapshot) {
        final serverItems = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return CartItemModel.fromJson(data);
        }).toList();
        if (serverItems.isNotEmpty) {
          _saveLocalCart(userId, serverItems);
        }
      }, onError: (err) {
        debugPrint('[CartRepository] Firestore cart sync bypassed: $err');
      });
    } catch (e) {
      debugPrint('[CartRepository] Firestore cart error: $e');
    }

    yield* controller.stream;
  }

  Future<void> addToCart(String userId, CartItemModel item) async {
    final items = await _loadLocalCart(userId);
    final index = items.indexWhere((it) => it.id == item.id || it.productId == item.productId);
    if (index >= 0) {
      final existing = items[index];
      items[index] = existing.copyWith(quantity: existing.quantity + item.quantity);
    } else {
      items.add(item);
    }
    await _saveLocalCart(userId, items);

    // Attempt firestore mirror in background
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.id);
      final doc = await docRef.get().timeout(const Duration(seconds: 1));
      if (doc.exists) {
        await docRef.update({'quantity': FieldValue.increment(item.quantity)});
      } else {
        await docRef.set(item.toJson());
      }
    } catch (_) {}
  }

  Future<void> updateQuantity(
      String userId, String itemId, int newQuantity) async {
    final items = await _loadLocalCart(userId);
    if (newQuantity <= 0) {
      items.removeWhere((it) => it.id == itemId || it.productId == itemId);
    } else {
      final index = items.indexWhere((it) => it.id == itemId || it.productId == itemId);
      if (index >= 0) {
        items[index] = items[index].copyWith(quantity: newQuantity);
      }
    }
    await _saveLocalCart(userId, items);

    // Attempt firestore mirror in background
    try {
      if (newQuantity <= 0) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(itemId)
            .delete()
            .timeout(const Duration(seconds: 1));
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(itemId)
            .update({'quantity': newQuantity})
            .timeout(const Duration(seconds: 1));
      }
    } catch (_) {}
  }

  Future<void> clearCart(String userId) async {
    await _saveLocalCart(userId, []);
  }
}
