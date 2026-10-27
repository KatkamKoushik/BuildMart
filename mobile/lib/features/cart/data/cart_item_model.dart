import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

@freezed
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String id,
    required String productId,
    required String title,
    required String brand,
    required double price,
    required String imageUrl,
    required int quantity,
    @Default('Unknown Shop') String shopName,
    @Default('unknown') String shopId,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}
