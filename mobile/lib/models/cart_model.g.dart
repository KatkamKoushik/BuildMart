// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemModelImpl _$$CartItemModelImplFromJson(Map<String, dynamic> json) =>
    _$CartItemModelImpl(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$$CartItemModelImplToJson(_$CartItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'quantity': instance.quantity,
    };

_$CartShopGroupModelImpl _$$CartShopGroupModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CartShopGroupModelImpl(
      shop: ShopModel.fromJson(json['shop'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );

Map<String, dynamic> _$$CartShopGroupModelImplToJson(
        _$CartShopGroupModelImpl instance) =>
    <String, dynamic>{
      'shop': instance.shop,
      'items': instance.items,
      'subtotal': instance.subtotal,
    };

_$CartModelImpl _$$CartModelImplFromJson(Map<String, dynamic> json) =>
    _$CartModelImpl(
      userId: json['userId'] as String,
      shopGroups: (json['shopGroups'] as List<dynamic>)
          .map((e) => CartShopGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      totalGst: (json['totalGst'] as num).toDouble(),
      totalDeliveryCharges: (json['totalDeliveryCharges'] as num).toDouble(),
    );

Map<String, dynamic> _$$CartModelImplToJson(_$CartModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'shopGroups': instance.shopGroups,
      'grandTotal': instance.grandTotal,
      'totalGst': instance.totalGst,
      'totalDeliveryCharges': instance.totalDeliveryCharges,
    };
