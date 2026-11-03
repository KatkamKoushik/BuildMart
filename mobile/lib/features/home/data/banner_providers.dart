import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/local_catalog_service.dart';

final bannersProvider = StreamProvider<List<String>>((ref) async* {
  final localCatalog = LocalCatalogService.instance;
  await localCatalog.ensureInitialized();
  if (localCatalog.banners.isNotEmpty) {
    yield localCatalog.banners;
  }

  try {
    yield* FirebaseFirestore.instance
        .collection('banners')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return (data['imageUrl'] ?? '').toString();
        }).where((url) => url.isNotEmpty).toList();
      }
      return localCatalog.banners;
    }).handleError((error) {
      debugPrint('[BannersProvider] Firestore fallback to local banners: $error');
      return localCatalog.banners;
    });
  } catch (e) {
    debugPrint('[BannersProvider] Firestore error: $e');
    if (localCatalog.banners.isNotEmpty) {
      yield localCatalog.banners;
    }
  }
});
