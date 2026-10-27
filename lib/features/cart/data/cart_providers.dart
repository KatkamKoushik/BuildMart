import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cart_item_model.dart';

// --- Save For Later Provider ---
class SaveForLaterNotifier extends StateNotifier<List<CartItemModel>> {
  SaveForLaterNotifier() : super([]);

  void saveForLater(CartItemModel item) {
    if (!state.any((p) => p.id == item.id)) {
      state = [...state, item];
    }
  }

  void moveToCart(CartItemModel item) {
    state = state.where((p) => p.id != item.id).toList();
  }
}

final saveForLaterProvider =
    StateNotifierProvider<SaveForLaterNotifier, List<CartItemModel>>((ref) {
  return SaveForLaterNotifier();
});

// --- Coupon Provider ---
class CouponNotifier extends StateNotifier<String?> {
  final FirebaseFirestore _firestore;

  CouponNotifier(this._firestore) : super(null);

  Future<bool> applyCoupon(String code) async {
    try {
      final doc =
          await _firestore.collection('coupons').doc(code.toUpperCase()).get();
      if (doc.exists && doc.data()?['active'] == true) {
        state = code.toUpperCase();
        return true;
      }
    } catch (e) {
      debugPrint('Error applying coupon: $e');
    }
    return false;
  }

  void removeCoupon() {
    state = null;
  }
}

final couponProvider = StateNotifierProvider<CouponNotifier, String?>((ref) {
  return CouponNotifier(FirebaseFirestore.instance);
});
