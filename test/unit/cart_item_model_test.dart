import 'package:flutter_test/flutter_test.dart';
import 'package:buildmart/features/cart/data/cart_item_model.dart';

void main() {
  group('CartItemModel Tests', () {
    const sampleCartJson = {
      'id': 'cart_item_1',
      'productId': 'prod_steel_02',
      'title': 'Tata Tiscon 550D TMT Rebars 12mm',
      'brand': 'Tata Steel',
      'price': 65000.0,
      'imageUrl': 'https://example.com/tmt.jpg',
      'quantity': 2,
      'shopName': 'Sri Lakshmi Steels',
      'shopId': 'shop_001',
    };

    test('deserializes from JSON properly', () {
      final cartItem = CartItemModel.fromJson(sampleCartJson);

      expect(cartItem.id, equals('cart_item_1'));
      expect(cartItem.productId, equals('prod_steel_02'));
      expect(cartItem.title, equals('Tata Tiscon 550D TMT Rebars 12mm'));
      expect(cartItem.brand, equals('Tata Steel'));
      expect(cartItem.price, equals(65000.0));
      expect(cartItem.quantity, equals(2));
      expect(cartItem.shopName, equals('Sri Lakshmi Steels'));
      expect(cartItem.shopId, equals('shop_001'));
    });

    test('serializes to JSON correctly', () {
      final cartItem = CartItemModel.fromJson(sampleCartJson);
      final json = cartItem.toJson();

      expect(json['id'], equals('cart_item_1'));
      expect(json['quantity'], equals(2));
      expect(json['price'], equals(65000.0));
    });

    test('calculates line total accurately', () {
      final cartItem = CartItemModel.fromJson(sampleCartJson);
      final lineTotal = cartItem.price * cartItem.quantity;

      expect(lineTotal, equals(130000.0));
    });
  });
}
