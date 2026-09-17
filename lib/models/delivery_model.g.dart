// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryAgentModelImpl _$$DeliveryAgentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DeliveryAgentModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      rating: (json['rating'] as num).toDouble(),
      vehicleNumber: json['vehicleNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$$DeliveryAgentModelImplToJson(
        _$DeliveryAgentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'rating': instance.rating,
      'vehicleNumber': instance.vehicleNumber,
      'photoUrl': instance.photoUrl,
    };

_$DeliveryModelImpl _$$DeliveryModelImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryModelImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      status: $enumDecode(_$DeliveryStatusEnumMap, json['status']),
      deliveryAddress: json['deliveryAddress'] as String,
      otp: json['otp'] as String,
      currentLatitude: (json['currentLatitude'] as num?)?.toDouble(),
      currentLongitude: (json['currentLongitude'] as num?)?.toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] == null
          ? null
          : DateTime.parse(json['estimatedDeliveryTime'] as String),
      agent: json['agent'] == null
          ? null
          : DeliveryAgentModel.fromJson(json['agent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DeliveryModelImplToJson(_$DeliveryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'status': _$DeliveryStatusEnumMap[instance.status]!,
      'deliveryAddress': instance.deliveryAddress,
      'otp': instance.otp,
      'currentLatitude': instance.currentLatitude,
      'currentLongitude': instance.currentLongitude,
      'estimatedDeliveryTime':
          instance.estimatedDeliveryTime?.toIso8601String(),
      'agent': instance.agent,
    };

const _$DeliveryStatusEnumMap = {
  DeliveryStatus.assigned: 'assigned',
  DeliveryStatus.pickedUp: 'pickedUp',
  DeliveryStatus.inTransit: 'inTransit',
  DeliveryStatus.outForDelivery: 'outForDelivery',
  DeliveryStatus.delivered: 'delivered',
  DeliveryStatus.failed: 'failed',
};
