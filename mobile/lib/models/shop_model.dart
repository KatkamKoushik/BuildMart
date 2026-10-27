import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_model.freezed.dart';
part 'shop_model.g.dart';

@freezed
class ShopModel with _$ShopModel {
  const factory ShopModel({
    required String id,
    required String name,
    required String gstin,
    required String ownerName,
    required String contactNumber,
    required String address,
    required double latitude,
    required double longitude,
    required double rating,
    required int totalReviews,
    required String openHours,
    String? bannerImageUrl,
    @Default(true) bool isVerified,
  }) = _ShopModel;

  factory ShopModel.fromJson(Map<String, dynamic> json) =>
      _$ShopModelFromJson(json);
}
