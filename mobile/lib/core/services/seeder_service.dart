import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    try {
      debugPrint('Loading seeded_data.json...');
      final String jsonString =
          await rootBundle.loadString('assets/seeded_data.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);

      debugPrint('Seeding Brands...');
      final brandsSnapshot = await _firestore.collection('brands').get();
      for (var doc in brandsSnapshot.docs) {
        await doc.reference.delete();
      }
      for (var brand in data['brands']) {
        await _firestore.collection('brands').doc(brand['id']).set(brand);
      }

      debugPrint('Seeding Categories...');
      final categoriesSnapshot =
          await _firestore.collection('categories').get();
      for (var doc in categoriesSnapshot.docs) {
        await doc.reference.delete();
      }
      for (var category in data['categories']) {
        await _firestore
            .collection('categories')
            .doc(category['id'])
            .set(category);
      }

      debugPrint('Seeding Products...');
      final productsSnapshot = await _firestore.collection('products').get();
      for (var doc in productsSnapshot.docs) {
        await doc.reference.delete();
      }
      for (var product in data['products']) {
        await _firestore.collection('products').doc(product['id']).set(product);
      }

      debugPrint('Seeding Banners...');
      final bannersSnapshot = await _firestore.collection('banners').get();
      for (var doc in bannersSnapshot.docs) {
        await doc.reference.delete();
      }
      for (var banner in data['banners']) {
        await _firestore.collection('banners').doc(banner['id']).set(banner);
      }

      if (data.containsKey('shops')) {
        debugPrint('Seeding Shops...');
        final shopsSnapshot = await _firestore.collection('shops').get();
        for (var doc in shopsSnapshot.docs) {
          await doc.reference.delete();
        }
        for (var shop in data['shops']) {
          await _firestore.collection('shops').doc(shop['id']).set(shop);
        }
      }

      debugPrint('Database Seeding Complete!');
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }
}
