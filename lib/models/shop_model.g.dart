// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShopModelImpl _$$ShopModelImplFromJson(Map<String, dynamic> json) =>
    _$ShopModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      gstin: json['gstin'] as String,
      ownerName: json['ownerName'] as String,
      contactNumber: json['contactNumber'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      openHours: json['openHours'] as String,
      bannerImageUrl: json['bannerImageUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? true,
    );

Map<String, dynamic> _$$ShopModelImplToJson(_$ShopModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'gstin': instance.gstin,
      'ownerName': instance.ownerName,
      'contactNumber': instance.contactNumber,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rating': instance.rating,
      'totalReviews': instance.totalReviews,
      'openHours': instance.openHours,
      'bannerImageUrl': instance.bannerImageUrl,
      'isVerified': instance.isVerified,
    };
