// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  return _OrderModel.fromJson(json);
}

/// @nodoc
mixin _$OrderModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  List<CartShopGroupModel> get shopGroups => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  PaymentModel get paymentDetails => throw _privateConstructorUsedError;
  DeliveryModel get deliveryDetails => throw _privateConstructorUsedError;

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderModelCopyWith<OrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderModelCopyWith<$Res> {
  factory $OrderModelCopyWith(
          OrderModel value, $Res Function(OrderModel) then) =
      _$OrderModelCopyWithImpl<$Res, OrderModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      List<CartShopGroupModel> shopGroups,
      double totalAmount,
      OrderStatus status,
      DateTime createdAt,
      PaymentModel paymentDetails,
      DeliveryModel deliveryDetails});

  $PaymentModelCopyWith<$Res> get paymentDetails;
  $DeliveryModelCopyWith<$Res> get deliveryDetails;
}

/// @nodoc
class _$OrderModelCopyWithImpl<$Res, $Val extends OrderModel>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? shopGroups = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? paymentDetails = null,
    Object? deliveryDetails = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      shopGroups: null == shopGroups
          ? _value.shopGroups
          : shopGroups // ignore: cast_nullable_to_non_nullable
              as List<CartShopGroupModel>,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paymentDetails: null == paymentDetails
          ? _value.paymentDetails
          : paymentDetails // ignore: cast_nullable_to_non_nullable
              as PaymentModel,
      deliveryDetails: null == deliveryDetails
          ? _value.deliveryDetails
          : deliveryDetails // ignore: cast_nullable_to_non_nullable
              as DeliveryModel,
    ) as $Val);
  }

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaymentModelCopyWith<$Res> get paymentDetails {
    return $PaymentModelCopyWith<$Res>(_value.paymentDetails, (value) {
      return _then(_value.copyWith(paymentDetails: value) as $Val);
    });
  }

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeliveryModelCopyWith<$Res> get deliveryDetails {
    return $DeliveryModelCopyWith<$Res>(_value.deliveryDetails, (value) {
      return _then(_value.copyWith(deliveryDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderModelImplCopyWith<$Res>
    implements $OrderModelCopyWith<$Res> {
  factory _$$OrderModelImplCopyWith(
          _$OrderModelImpl value, $Res Function(_$OrderModelImpl) then) =
      __$$OrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      List<CartShopGroupModel> shopGroups,
      double totalAmount,
      OrderStatus status,
      DateTime createdAt,
      PaymentModel paymentDetails,
      DeliveryModel deliveryDetails});

  @override
  $PaymentModelCopyWith<$Res> get paymentDetails;
  @override
  $DeliveryModelCopyWith<$Res> get deliveryDetails;
}

/// @nodoc
class __$$OrderModelImplCopyWithImpl<$Res>
    extends _$OrderModelCopyWithImpl<$Res, _$OrderModelImpl>
    implements _$$OrderModelImplCopyWith<$Res> {
  __$$OrderModelImplCopyWithImpl(
      _$OrderModelImpl _value, $Res Function(_$OrderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? shopGroups = null,
    Object? totalAmount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? paymentDetails = null,
    Object? deliveryDetails = null,
  }) {
    return _then(_$OrderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      shopGroups: null == shopGroups
          ? _value._shopGroups
          : shopGroups // ignore: cast_nullable_to_non_nullable
              as List<CartShopGroupModel>,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paymentDetails: null == paymentDetails
          ? _value.paymentDetails
          : paymentDetails // ignore: cast_nullable_to_non_nullable
              as PaymentModel,
      deliveryDetails: null == deliveryDetails
          ? _value.deliveryDetails
          : deliveryDetails // ignore: cast_nullable_to_non_nullable
              as DeliveryModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderModelImpl implements _OrderModel {
  const _$OrderModelImpl(
      {required this.id,
      required this.userId,
      required final List<CartShopGroupModel> shopGroups,
      required this.totalAmount,
      required this.status,
      required this.createdAt,
      required this.paymentDetails,
      required this.deliveryDetails})
      : _shopGroups = shopGroups;

  factory _$OrderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderModelImplFromJson(json);

  @override
  final String id;
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
  final double totalAmount;
  @override
  final OrderStatus status;
  @override
  final DateTime createdAt;
  @override
  final PaymentModel paymentDetails;
  @override
  final DeliveryModel deliveryDetails;

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, shopGroups: $shopGroups, totalAmount: $totalAmount, status: $status, createdAt: $createdAt, paymentDetails: $paymentDetails, deliveryDetails: $deliveryDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._shopGroups, _shopGroups) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.paymentDetails, paymentDetails) ||
                other.paymentDetails == paymentDetails) &&
            (identical(other.deliveryDetails, deliveryDetails) ||
                other.deliveryDetails == deliveryDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      const DeepCollectionEquality().hash(_shopGroups),
      totalAmount,
      status,
      createdAt,
      paymentDetails,
      deliveryDetails);

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      __$$OrderModelImplCopyWithImpl<_$OrderModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderModelImplToJson(
      this,
    );
  }
}

abstract class _OrderModel implements OrderModel {
  const factory _OrderModel(
      {required final String id,
      required final String userId,
      required final List<CartShopGroupModel> shopGroups,
      required final double totalAmount,
      required final OrderStatus status,
      required final DateTime createdAt,
      required final PaymentModel paymentDetails,
      required final DeliveryModel deliveryDetails}) = _$OrderModelImpl;

  factory _OrderModel.fromJson(Map<String, dynamic> json) =
      _$OrderModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  List<CartShopGroupModel> get shopGroups;
  @override
  double get totalAmount;
  @override
  OrderStatus get status;
  @override
  DateTime get createdAt;
  @override
  PaymentModel get paymentDetails;
  @override
  DeliveryModel get deliveryDetails;

  /// Create a copy of OrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderModelImplCopyWith<_$OrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
