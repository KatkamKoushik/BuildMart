import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_model.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// You need to override this in main.dart: sharedPreferencesProvider.overrideWithValue(prefs)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// --- Wishlist Provider ---
class WishlistNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _key = 'wishlist_ids';

  WishlistNotifier(this._prefs, this._firestore, this._auth) : super(_load(_prefs)) {
    _syncFromCloud();
  }

  static Set<String> _load(SharedPreferences prefs) {
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> _syncFromCloud() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('wishlist')) {
          final cloudList = List<String>.from(doc.data()!['wishlist']);
          state = {...state, ...cloudList};
          _prefs.setStringList(_key, state.toList());
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> _syncToCloud() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'wishlist': state.toList(),
        }, SetOptions(merge: true));
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void toggleWishlist(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
    _prefs.setStringList(_key, state.toList());
    _syncToCloud();
  }

  bool isInWishlist(String productId) {
    return state.contains(productId);
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  return WishlistNotifier(
    ref.watch(sharedPreferencesProvider),
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

// --- Recently Viewed Provider ---
class RecentlyViewedNotifier extends StateNotifier<List<ProductModel>> {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _key = 'recently_viewed_products';

  RecentlyViewedNotifier(this._prefs, this._firestore, this._auth) : super(_load(_prefs)) {
    _syncFromCloud();
  }

  static List<ProductModel> _load(SharedPreferences prefs) {
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) => ProductModel.fromJson(jsonDecode(s))).toList();
  }

  Future<void> _syncFromCloud() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('recently_viewed')) {
          final cloudList = (doc.data()!['recently_viewed'] as List)
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList();
          
          // Merge logic: keep local if more recent, otherwise use cloud (simplified: just use cloud if available and larger)
          if (cloudList.length > state.length) {
            state = cloudList;
            _prefs.setStringList(_key, state.map((p) => jsonEncode(p.toJson())).toList());
          }
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> _syncToCloud() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'recently_viewed': state.map((p) => p.toJson()).toList(),
        }, SetOptions(merge: true));
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void addProduct(ProductModel product) {
    // Remove if already exists so we can move it to the front
    final currentList = state.where((p) => p.id != product.id).toList();
    currentList.insert(0, product);
    
    // Keep only the last 15 products
    if (currentList.length > 15) {
      state = currentList.sublist(0, 15);
    } else {
      state = currentList;
    }
    
    _prefs.setStringList(_key, state.map((p) => jsonEncode(p.toJson())).toList());
    _syncToCloud();
  }
}

final recentlyViewedProvider = StateNotifierProvider<RecentlyViewedNotifier, List<ProductModel>>((ref) {
  return RecentlyViewedNotifier(
    ref.watch(sharedPreferencesProvider),
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

// --- Compare Products Provider ---
class CompareProductsNotifier extends StateNotifier<List<ProductModel>> {
  CompareProductsNotifier() : super([]);

  void toggleCompare(ProductModel product) {
    if (state.any((p) => p.id == product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      if (state.length < 3) {
        state = [...state, product];
      }
    }
  }

  bool isComparing(String productId) {
    return state.any((p) => p.id == productId);
  }
}

final compareProductsProvider = StateNotifierProvider<CompareProductsNotifier, List<ProductModel>>((ref) {
  return CompareProductsNotifier();
});
