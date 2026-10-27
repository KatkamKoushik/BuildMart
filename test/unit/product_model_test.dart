import 'package:flutter_test/flutter_test.dart';
import 'package:buildmart/features/products/data/product_model.dart';

void main() {
  group('ProductModel Tests', () {
    const sampleJson = {
      'id': 'prod_cement_01',
      'title': 'UltraTech Super Cement 50kg',
      'brand': 'UltraTech',
      'price': 390.0,
      'originalPrice': 420.0,
      'imageUrl': 'https://example.com/cement.jpg',
      'rating': 4.8,
      'reviews': 120,
      'inStock': true,
      'deliveryTime': '2 days',
    };

    test('deserializes correctly from JSON', () {
      final product = ProductModel.fromJson(sampleJson);

      expect(product.id, equals('prod_cement_01'));
      expect(product.title, equals('UltraTech Super Cement 50kg'));
      expect(product.brand, equals('UltraTech'));
      expect(product.price, equals(390.0));
      expect(product.originalPrice, equals(420.0));
      expect(product.rating, equals(4.8));
      expect(product.reviews, equals(120));
      expect(product.inStock, isTrue);
      expect(product.deliveryTime, equals('2 days'));
    });

    test('serializes correctly to JSON', () {
      final product = ProductModel.fromJson(sampleJson);
      final json = product.toJson();

      expect(json['id'], equals('prod_cement_01'));
      expect(json['title'], equals('UltraTech Super Cement 50kg'));
      expect(json['price'], equals(390.0));
      expect(json['inStock'], isTrue);
    });

    test('defaults inStock to true if omitted', () {
      final jsonWithoutStock = Map<String, dynamic>.from(sampleJson)
        ..remove('inStock');
      final product = ProductModel.fromJson(jsonWithoutStock);

      expect(product.inStock, isTrue);
    });
  });
}
