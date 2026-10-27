import 'package:freezed_annotation/freezed_annotation.dart';
import 'brand_model.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required double originalPrice,
    required BrandModel brand,
    required String categoryId,
    required String shopId,
    required List<String> imageUrls,
    required Map<String, String> specifications,
    required double rating,
    required int totalReviews,
    required int stockQuantity,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
