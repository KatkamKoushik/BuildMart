import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

enum PaymentMethod { upi, card, netbanking, wallet, cod }

enum PaymentStatus { pending, success, failed, refunded }

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String orderId,
    required double amount,
    required PaymentMethod method,
    required PaymentStatus status,
    required DateTime transactionDate,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
}
