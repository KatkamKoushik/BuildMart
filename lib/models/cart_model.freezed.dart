// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) {
  return _CartItemModel.fromJson(json);
}

/// @nodoc
mixin _$CartItemModel {
  String get id => throw _privateConstructorUsedError;
  ProductModel get product => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  /// Serializes this CartItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemModelCopyWith<CartItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemModelCopyWith<$Res> {
  factory $CartItemModelCopyWith(
          CartItemModel value, $Res Function(CartItemModel) then) =
      _$CartItemModelCopyWithImpl<$Res, CartItemModel>;
  @useResult
  $Res call({String id, ProductModel product, int quantity});

  $ProductModelCopyWith<$Res> get product;
}

/// @nodoc
class _$CartItemModelCopyWithImpl<$Res, $Val extends CartItemModel>
    implements $CartItemModelCopyWith<$Res> {
  _$CartItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? product = null,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      product: null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductModelCopyWith<$Res> get product {
    return $ProductModelCopyWith<$Res>(_value.product, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartItemModelImplCopyWith<$Res>
    implements $CartItemModelCopyWith<$Res> {
  factory _$$CartItemModelImplCopyWith(
          _$CartItemModelImpl value, $Res Function(_$CartItemModelImpl) then) =
      __$$CartItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, ProductModel product, int quantity});

  @override
  $ProductModelCopyWith<$Res> get product;
}

/// @nodoc
class __$$CartItemModelImplCopyWithImpl<$Res>
    extends _$CartItemModelCopyWithImpl<$Res, _$CartItemModelImpl>
    implements _$$CartItemModelImplCopyWith<$Res> {
  __$$CartItemModelImplCopyWithImpl(
      _$CartItemModelImpl _value, $Res Function(_$CartItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? product = null,
    Object? quantity = null,
  }) {
    return _then(_$CartItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      product: null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemModelImpl implements _CartItemModel {
  const _$CartItemModelImpl(
      {required this.id, required this.product, required this.quantity});

  factory _$CartItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemModelImplFromJson(json);

  @override
  final String id;
  @override
  final ProductModel product;
  @override
  final int quantity;

  @override
  String toString() {
    return 'CartItemModel(id: $id, product: $product, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, product, quantity);

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      __$$CartItemModelImplCopyWithImpl<_$CartItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemModelImplToJson(
      this,
    );
  }
}

abstract class _CartItemModel implements CartItemModel {
  const factory _CartItemModel(
      {required final String id,
      required final ProductModel product,
      required final int quantity}) = _$CartItemModelImpl;

  factory _CartItemModel.fromJson(Map<String, dynamic> json) =
      _$CartItemModelImpl.fromJson;

  @override
  String get id;
  @override
  ProductModel get product;
  @override
  int get quantity;

  /// Create a copy of CartItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemModelImplCopyWith<_$CartItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CartShopGroupModel _$CartShopGroupModelFromJson(Map<String, dynamic> json) {
  return _CartShopGroupModel.fromJson(json);
}

/// @nodoc
mixin _$CartShopGroupModel {
  ShopModel get shop => throw _privateConstructorUsedError;
  List<CartItemModel> get items => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;

  /// Serializes this CartShopGroupModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartShopGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartShopGroupModelCopyWith<CartShopGroupModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartShopGroupModelCopyWith<$Res> {
  factory $CartShopGroupModelCopyWith(
          CartShopGroupModel value, $Res Function(CartShopGroupModel) then) =
      _$CartShopGroupModelCopyWithImpl<$Res, CartShopGroupModel>;
  @useResult
  $Res call({ShopModel shop, List<CartItemModel> items, double subtotal});

  $ShopModelCopyWith<$Res> get shop;
}

/// @nodoc
class _$CartShopGroupModelCopyWithImpl<$Res, $Val extends CartShopGroupModel>
    implements $CartShopGroupModelCopyWith<$Res> {
  _$CartShopGroupModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartShopGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shop = null,
    Object? items = null,
    Object? subtotal = null,
  }) {
    return _then(_value.copyWith(
      shop: null == shop
          ? _value.shop
          : shop // ignore: cast_nullable_to_non_nullable
              as ShopModel,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemModel>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }

  /// Create a copy of CartShopGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShopModelCopyWith<$Res> get shop {
    return $ShopModelCopyWith<$Res>(_value.shop, (value) {
      return _then(_value.copyWith(shop: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartShopGroupModelImplCopyWith<$Res>
    implements $CartShopGroupModelCopyWith<$Res> {
  factory _$$CartShopGroupModelImplCopyWith(_$CartShopGroupModelImpl value,
          $Res Function(_$CartShopGroupModelImpl) then) =
      __$$CartShopGroupModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ShopModel shop, List<CartItemModel> items, double subtotal});

  @override
  $ShopModelCopyWith<$Res> get shop;
}

/// @nodoc
class __$$CartShopGroupModelImplCopyWithImpl<$Res>
    extends _$CartShopGroupModelCopyWithImpl<$Res, _$CartShopGroupModelImpl>
    implements _$$CartShopGroupModelImplCopyWith<$Res> {
  __$$CartShopGroupModelImplCopyWithImpl(_$CartShopGroupModelImpl _value,
      $Res Function(_$CartShopGroupModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartShopGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shop = null,
    Object? items = null,
    Object? subtotal = null,
  }) {
    return _then(_$CartShopGroupModelImpl(
      shop: null == shop
          ? _value.shop
          : shop // ignore: cast_nullable_to_non_nullable
              as ShopModel,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItemModel>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartShopGroupModelImpl implements _CartShopGroupModel {
  const _$CartShopGroupModelImpl(
      {required this.shop,
      required final List<CartItemModel> items,
      required this.subtotal})
      : _items = items;

  factory _$CartShopGroupModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartShopGroupModelImplFromJson(json);

  @override
  final ShopModel shop;
  final List<CartItemModel> _items;
  @override
  List<CartItemModel> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double subtotal;

  @override
  String toString() {
    return 'CartShopGroupModel(shop: $shop, items: $items, subtotal: $subtotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartShopGroupModelImpl &&
            (identical(other.shop, shop) || other.shop == shop) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, shop, const DeepCollectionEquality().hash(_items), subtotal);

  /// Create a copy of CartShopGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartShopGroupModelImplCopyWith<_$CartShopGroupModelImpl> get copyWith =>
      __$$CartShopGroupModelImplCopyWithImpl<_$CartShopGroupModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartShopGroupModelImplToJson(
      this,
    );
  }
}

abstract class _CartShopGroupModel implements CartShopGroupModel {
  const factory _CartShopGroupModel(
      {required final ShopModel shop,
      required final List<CartItemModel> items,
      required final double subtotal}) = _$CartShopGroupModelImpl;

  factory _CartShopGroupModel.fromJson(Map<String, dynamic> json) =
      _$CartShopGroupModelImpl.fromJson;

  @override
  ShopModel get shop;
  @override
  List<CartItemModel> get items;
  @override
  double get subtotal;

  /// Create a copy of CartShopGroupModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartShopGroupModelImplCopyWith<_$CartShopGroupModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CartModel _$CartModelFromJson(Map<String, dynamic> json) {
  return _CartModel.fromJson(json);
}

/// @nodoc
mixin _$CartModel {
  String get userId => throw _privateConstructorUsedError;
  List<CartShopGroupModel> get shopGroups => throw _privateConstructorUsedError;
  double get grandTotal => throw _privateConstructorUsedError;
  double get totalGst => throw _privateConstructorUsedError;
  double get totalDeliveryCharges => throw _privateConstructorUsedError;

  /// Serializes this CartModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartModelCopyWith<CartModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartModelCopyWith<$Res> {
  factory $CartModelCopyWith(CartModel value, $Res Function(CartModel) then) =
      _$CartModelCopyWithImpl<$Res, CartModel>;
  @useResult
  $Res call(
      {String userId,
      List<CartShopGroupModel> shopGroups,
      double grandTotal,
      double totalGst,
      double totalDeliveryCharges});
}

/// @nodoc
class _$CartModelCopyWithImpl<$Res, $Val extends CartModel>
    implements $CartModelCopyWith<$Res> {
  _$CartModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? shopGroups = null,
    Object? grandTotal = null,
    Object? totalGst = null,
    Object? totalDeliveryCharges = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      shopGroups: null == shopGroups
          ? _value.shopGroups
          : shopGroups // ignore: cast_nullable_to_non_nullable
              as List<CartShopGroupModel>,
      grandTotal: null == grandTotal
          ? _value.grandTotal
          : grandTotal // ignore: cast_nullable_to_non_nullable
              as double,
      totalGst: null == totalGst
          ? _value.totalGst
          : totalGst // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeliveryCharges: null == totalDeliveryCharges
          ? _value.totalDeliveryCharges
          : totalDeliveryCharges // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartModelImplCopyWith<$Res>
    implements $CartModelCopyWith<$Res> {
  factory _$$CartModelImplCopyWith(
          _$CartModelImpl value, $Res Function(_$CartModelImpl) then) =
      __$$CartModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      List<CartShopGroupModel> shopGroups,
      double grandTotal,
      double totalGst,
      double totalDeliveryCharges});
}

/// @nodoc
class __$$CartModelImplCopyWithImpl<$Res>
    extends _$CartModelCopyWithImpl<$Res, _$CartModelImpl>
    implements _$$CartModelImplCopyWith<$Res> {
  __$$CartModelImplCopyWithImpl(
      _$CartModelImpl _value, $Res Function(_$CartModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? shopGroups = null,
    Object? grandTotal = null,
    Object? totalGst = null,
    Object? totalDeliveryCharges = null,
  }) {
    return _then(_$CartModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      shopGroups: null == shopGroups
          ? _value._shopGroups
          : shopGroups // ignore: cast_nullable_to_non_nullable
              as List<CartShopGroupModel>,
      grandTotal: null == grandTotal
          ? _value.grandTotal
          : grandTotal // ignore: cast_nullable_to_non_nullable
              as double,
      totalGst: null == totalGst
          ? _value.totalGst
          : totalGst // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeliveryCharges: null == totalDeliveryCharges
          ? _value.totalDeliveryCharges
          : totalDeliveryCharges // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CartModelImpl implements _CartModel {
  const _$CartModelImpl(
      {required this.userId,
      required final List<CartShopGroupModel> shopGroups,
      required this.grandTotal,
      required this.totalGst,
      required this.totalDeliveryCharges})
      : _shopGroups = shopGroups;

  factory _$CartModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartModelImplFromJson(json);

  @override
  final String userId;
  final List<CartShopGroupModel> _shopGroups;
  @override
  List<CartShopGroupModel> get shopGroups {
    if (_shopGroups is EqualUnmodifiableListView) return _shopGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shopGroups);
  }

  @override
  final double grandTotal;
  @override
  final double totalGst;
  @override
  final double totalDeliveryCharges;

  @override
  String toString() {
    return 'CartModel(userId: $userId, shopGroups: $shopGroups, grandTotal: $grandTotal, totalGst: $totalGst, totalDeliveryCharges: $totalDeliveryCharges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._shopGroups, _shopGroups) &&
            (identical(other.grandTotal, grandTotal) ||
                other.grandTotal == grandTotal) &&
            (identical(other.totalGst, totalGst) ||
                other.totalGst == totalGst) &&
            (identical(other.totalDeliveryCharges, totalDeliveryCharges) ||
                other.totalDeliveryCharges == totalDeliveryCharges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      const DeepCollectionEquality().hash(_shopGroups),
      grandTotal,
      totalGst,
      totalDeliveryCharges);

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartModelImplCopyWith<_$CartModelImpl> get copyWith =>
      __$$CartModelImplCopyWithImpl<_$CartModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartModelImplToJson(
      this,
    );
  }
}

abstract class _CartModel implements CartModel {
  const factory _CartModel(
      {required final String userId,
      required final List<CartShopGroupModel> shopGroups,
      required final double grandTotal,
      required final double totalGst,
      required final double totalDeliveryCharges}) = _$CartModelImpl;

  factory _CartModel.fromJson(Map<String, dynamic> json) =
      _$CartModelImpl.fromJson;

  @override
  String get userId;
  @override
  List<CartShopGroupModel> get shopGroups;
  @override
  double get grandTotal;
  @override
  double get totalGst;
  @override
  double get totalDeliveryCharges;

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartModelImplCopyWith<_$CartModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
