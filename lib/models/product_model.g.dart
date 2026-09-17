// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      brand: BrandModel.fromJson(json['brand'] as Map<String, dynamic>),
      categoryId: json['categoryId'] as String,
      shopId: json['shopId'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      specifications: Map<String, String>.from(json['specifications'] as Map),
      rating: (json['rating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      stockQuantity: (json['stockQuantity'] as num).toInt(),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'brand': instance.brand,
      'categoryId': instance.categoryId,
      'shopId': instance.shopId,
      'imageUrls': instance.imageUrls,
      'specifications': instance.specifications,
      'rating': instance.rating,
      'totalReviews': instance.totalReviews,
      'stockQuantity': instance.stockQuantity,
    };
