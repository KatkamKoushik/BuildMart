import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_model.freezed.dart';
part 'delivery_model.g.dart';

enum DeliveryStatus {
  assigned,
  pickedUp,
  inTransit,
  outForDelivery,
  delivered,
  failed
}

@freezed
class DeliveryAgentModel with _$DeliveryAgentModel {
  const factory DeliveryAgentModel({
    required String id,
    required String name,
    required String phone,
    required double rating,
    String? vehicleNumber,
    String? photoUrl,
  }) = _DeliveryAgentModel;

  factory DeliveryAgentModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryAgentModelFromJson(json);
}

@freezed
class DeliveryModel with _$DeliveryModel {
  const factory DeliveryModel({
    required String id,
    required String orderId,
    required DeliveryStatus status,
    required String deliveryAddress,
    required String otp,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? estimatedDeliveryTime,
    DeliveryAgentModel? agent,
  }) = _DeliveryModel;

  factory DeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryModelFromJson(json);
}
