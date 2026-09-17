import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';
import 'shop_model.dart';

part 'cart_model.freezed.dart';
part 'cart_model.g.dart';

@freezed
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String id,
    required ProductModel product,
    required int quantity,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => _$CartItemModelFromJson(json);
}

@freezed
class CartShopGroupModel with _$CartShopGroupModel {
  const factory CartShopGroupModel({
    required ShopModel shop,
    required List<CartItemModel> items,
    required double subtotal,
  }) = _CartShopGroupModel;

  factory CartShopGroupModel.fromJson(Map<String, dynamic> json) => _$CartShopGroupModelFromJson(json);
}

@freezed
class CartModel with _$CartModel {
  const factory CartModel({
    required String userId,
    required List<CartShopGroupModel> shopGroups,
    required double grandTotal,
    required double totalGst,
    required double totalDeliveryCharges,
  }) = _CartModel;

  factory CartModel.fromJson(Map<String, dynamic> json) => _$CartModelFromJson(json);
}
