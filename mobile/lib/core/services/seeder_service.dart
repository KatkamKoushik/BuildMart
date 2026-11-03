import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_catalog_service.dart';

class SeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    // 1. Always load and refresh local catalog in memory and state
    debugPrint('[SeederService] Loading local catalog from assets/seeded_data.json...');
    await LocalCatalogService.instance.loadFromAssets();

    // 2. Attempt Firestore sync only if Cloud Firestore server database is active
    try {
      debugPrint('[SeederService] Checking Cloud Firestore server database availability...');
      final String jsonString =
          await rootBundle.loadString('assets/seeded_data.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Probe Firestore server directly with a 2s timeout
      await _firestore
          .collection('health')
          .doc('probe')
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 2));

      debugPrint('[SeederService] Cloud Firestore reachable. Seeding collections...');
      // Seed Brands
      for (var brand in data['brands'] ?? []) {
        await _firestore.collection('brands').doc(brand['id']).set(brand);
      }

      // Seed Categories
      for (var category in data['categories'] ?? []) {
        await _firestore
            .collection('categories')
            .doc(category['id'])
            .set(category);
      }

      // Seed Products
      for (var product in data['products'] ?? []) {
        await _firestore.collection('products').doc(product['id']).set(product);
      }

      // Seed Banners
      for (var banner in data['banners'] ?? []) {
        await _firestore.collection('banners').doc(banner['id']).set(banner);
      }

      // Seed Shops
      for (var shop in data['shops'] ?? []) {
        await _firestore.collection('shops').doc(shop['id']).set(shop);
      }

      debugPrint('[SeederService] Cloud Firestore Seeding Complete!');
    } catch (e) {
      debugPrint(
          '[SeederService] Notice: Cloud Firestore sync bypassed ($e). Offline-first local catalog is fully active.');
    }
  }
}
