import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String title,
    required String brand,
    required double price,
    double? originalPrice,
    required String imageUrl,
    required double rating,
    required int reviews,
    @Default(true) bool inStock,
    String? deliveryTime,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
