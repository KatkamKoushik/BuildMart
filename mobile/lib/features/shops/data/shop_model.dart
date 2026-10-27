import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_model.freezed.dart';
part 'shop_model.g.dart';

@freezed
class ShopModel with _$ShopModel {
  const factory ShopModel({
    required String id,
    required String name,
    required String coverImageUrl,
    required String logoUrl,
    required double rating,
    required int reviewCount,
    required String address,
    required String distance,
    @Default(true) bool isOpen,
    @Default([]) List<String> categories,
  }) = _ShopModel;

  factory ShopModel.fromJson(Map<String, dynamic> json) =>
      _$ShopModelFromJson(json);
}
