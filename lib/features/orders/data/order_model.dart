import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String status, // 'placed', 'confirmed', 'shipped', 'out_for_delivery', 'delivered'
    required double totalAmount,
    required DateTime createdAt,
    required String driverName,
    required String driverPhone,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
}
