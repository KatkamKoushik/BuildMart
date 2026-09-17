import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_model.dart';
import 'payment_model.dart';
import 'delivery_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

enum OrderStatus { pending, confirmed, processing, packed, outForDelivery, delivered, cancelled }

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String userId,
    required List<CartShopGroupModel> shopGroups,
    required double totalAmount,
    required OrderStatus status,
    required DateTime createdAt,
    required PaymentModel paymentDetails,
    required DeliveryModel deliveryDetails,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
}
