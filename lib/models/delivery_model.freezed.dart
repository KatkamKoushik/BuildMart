// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeliveryAgentModel _$DeliveryAgentModelFromJson(Map<String, dynamic> json) {
  return _DeliveryAgentModel.fromJson(json);
}

/// @nodoc
mixin _$DeliveryAgentModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  String? get vehicleNumber => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Serializes this DeliveryAgentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryAgentModelCopyWith<DeliveryAgentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryAgentModelCopyWith<$Res> {
  factory $DeliveryAgentModelCopyWith(
          DeliveryAgentModel value, $Res Function(DeliveryAgentModel) then) =
      _$DeliveryAgentModelCopyWithImpl<$Res, DeliveryAgentModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String phone,
      double rating,
      String? vehicleNumber,
      String? photoUrl});
}

/// @nodoc
class _$DeliveryAgentModelCopyWithImpl<$Res, $Val extends DeliveryAgentModel>
    implements $DeliveryAgentModelCopyWith<$Res> {
  _$DeliveryAgentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? rating = null,
    Object? vehicleNumber = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      vehicleNumber: freezed == vehicleNumber
          ? _value.vehicleNumber
          : vehicleNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeliveryAgentModelImplCopyWith<$Res>
    implements $DeliveryAgentModelCopyWith<$Res> {
  factory _$$DeliveryAgentModelImplCopyWith(_$DeliveryAgentModelImpl value,
          $Res Function(_$DeliveryAgentModelImpl) then) =
      __$$DeliveryAgentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String phone,
      double rating,
      String? vehicleNumber,
      String? photoUrl});
}

/// @nodoc
class __$$DeliveryAgentModelImplCopyWithImpl<$Res>
    extends _$DeliveryAgentModelCopyWithImpl<$Res, _$DeliveryAgentModelImpl>
    implements _$$DeliveryAgentModelImplCopyWith<$Res> {
  __$$DeliveryAgentModelImplCopyWithImpl(_$DeliveryAgentModelImpl _value,
      $Res Function(_$DeliveryAgentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeliveryAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = null,
    Object? rating = null,
    Object? vehicleNumber = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(_$DeliveryAgentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      vehicleNumber: freezed == vehicleNumber
          ? _value.vehicleNumber
          : vehicleNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryAgentModelImpl implements _DeliveryAgentModel {
  const _$DeliveryAgentModelImpl(
      {required this.id,
      required this.name,
      required this.phone,
      required this.rating,
      this.vehicleNumber,
      this.photoUrl});

  factory _$DeliveryAgentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryAgentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String phone;
  @override
  final double rating;
  @override
  final String? vehicleNumber;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'DeliveryAgentModel(id: $id, name: $name, phone: $phone, rating: $rating, vehicleNumber: $vehicleNumber, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryAgentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.vehicleNumber, vehicleNumber) ||
                other.vehicleNumber == vehicleNumber) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, phone, rating, vehicleNumber, photoUrl);

  /// Create a copy of DeliveryAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryAgentModelImplCopyWith<_$DeliveryAgentModelImpl> get copyWith =>
      __$$DeliveryAgentModelImplCopyWithImpl<_$DeliveryAgentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryAgentModelImplToJson(
      this,
    );
  }
}

abstract class _DeliveryAgentModel implements DeliveryAgentModel {
  const factory _DeliveryAgentModel(
      {required final String id,
      required final String name,
      required final String phone,
      required final double rating,
      final String? vehicleNumber,
      final String? photoUrl}) = _$DeliveryAgentModelImpl;

  factory _DeliveryAgentModel.fromJson(Map<String, dynamic> json) =
      _$DeliveryAgentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get phone;
  @override
  double get rating;
  @override
  String? get vehicleNumber;
  @override
  String? get photoUrl;

  /// Create a copy of DeliveryAgentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryAgentModelImplCopyWith<_$DeliveryAgentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeliveryModel _$DeliveryModelFromJson(Map<String, dynamic> json) {
  return _DeliveryModel.fromJson(json);
}

/// @nodoc
mixin _$DeliveryModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  DeliveryStatus get status => throw _privateConstructorUsedError;
  String get deliveryAddress => throw _privateConstructorUsedError;
  String get otp => throw _privateConstructorUsedError;
  double? get currentLatitude => throw _privateConstructorUsedError;
  double? get currentLongitude => throw _privateConstructorUsedError;
  DateTime? get estimatedDeliveryTime => throw _privateConstructorUsedError;
  DeliveryAgentModel? get agent => throw _privateConstructorUsedError;

  /// Serializes this DeliveryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryModelCopyWith<DeliveryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryModelCopyWith<$Res> {
  factory $DeliveryModelCopyWith(
          DeliveryModel value, $Res Function(DeliveryModel) then) =
      _$DeliveryModelCopyWithImpl<$Res, DeliveryModel>;
  @useResult
  $Res call(
      {String id,
      String orderId,
      DeliveryStatus status,
      String deliveryAddress,
      String otp,
      double? currentLatitude,
      double? currentLongitude,
      DateTime? estimatedDeliveryTime,
      DeliveryAgentModel? agent});

  $DeliveryAgentModelCopyWith<$Res>? get agent;
}

/// @nodoc
class _$DeliveryModelCopyWithImpl<$Res, $Val extends DeliveryModel>
    implements $DeliveryModelCopyWith<$Res> {
  _$DeliveryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? status = null,
    Object? deliveryAddress = null,
    Object? otp = null,
    Object? currentLatitude = freezed,
    Object? currentLongitude = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? agent = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DeliveryStatus,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
      currentLatitude: freezed == currentLatitude
          ? _value.currentLatitude
          : currentLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      currentLongitude: freezed == currentLongitude
          ? _value.currentLongitude
          : currentLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedDeliveryTime: freezed == estimatedDeliveryTime
          ? _value.estimatedDeliveryTime
          : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      agent: freezed == agent
          ? _value.agent
          : agent // ignore: cast_nullable_to_non_nullable
              as DeliveryAgentModel?,
    ) as $Val);
  }

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeliveryAgentModelCopyWith<$Res>? get agent {
    if (_value.agent == null) {
      return null;
    }

    return $DeliveryAgentModelCopyWith<$Res>(_value.agent!, (value) {
      return _then(_value.copyWith(agent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeliveryModelImplCopyWith<$Res>
    implements $DeliveryModelCopyWith<$Res> {
  factory _$$DeliveryModelImplCopyWith(
          _$DeliveryModelImpl value, $Res Function(_$DeliveryModelImpl) then) =
      __$$DeliveryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      DeliveryStatus status,
      String deliveryAddress,
      String otp,
      double? currentLatitude,
      double? currentLongitude,
      DateTime? estimatedDeliveryTime,
      DeliveryAgentModel? agent});

  @override
  $DeliveryAgentModelCopyWith<$Res>? get agent;
}

/// @nodoc
class __$$DeliveryModelImplCopyWithImpl<$Res>
    extends _$DeliveryModelCopyWithImpl<$Res, _$DeliveryModelImpl>
    implements _$$DeliveryModelImplCopyWith<$Res> {
  __$$DeliveryModelImplCopyWithImpl(
      _$DeliveryModelImpl _value, $Res Function(_$DeliveryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? status = null,
    Object? deliveryAddress = null,
    Object? otp = null,
    Object? currentLatitude = freezed,
    Object? currentLongitude = freezed,
    Object? estimatedDeliveryTime = freezed,
    Object? agent = freezed,
  }) {
    return _then(_$DeliveryModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DeliveryStatus,
      deliveryAddress: null == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String,
      otp: null == otp
          ? _value.otp
          : otp // ignore: cast_nullable_to_non_nullable
              as String,
      currentLatitude: freezed == currentLatitude
          ? _value.currentLatitude
          : currentLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      currentLongitude: freezed == currentLongitude
          ? _value.currentLongitude
          : currentLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedDeliveryTime: freezed == estimatedDeliveryTime
          ? _value.estimatedDeliveryTime
          : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      agent: freezed == agent
          ? _value.agent
          : agent // ignore: cast_nullable_to_non_nullable
              as DeliveryAgentModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryModelImpl implements _DeliveryModel {
  const _$DeliveryModelImpl(
      {required this.id,
      required this.orderId,
      required this.status,
      required this.deliveryAddress,
      required this.otp,
      this.currentLatitude,
      this.currentLongitude,
      this.estimatedDeliveryTime,
      this.agent});

  factory _$DeliveryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final DeliveryStatus status;
  @override
  final String deliveryAddress;
  @override
  final String otp;
  @override
  final double? currentLatitude;
  @override
  final double? currentLongitude;
  @override
  final DateTime? estimatedDeliveryTime;
  @override
  final DeliveryAgentModel? agent;

  @override
  String toString() {
    return 'DeliveryModel(id: $id, orderId: $orderId, status: $status, deliveryAddress: $deliveryAddress, otp: $otp, currentLatitude: $currentLatitude, currentLongitude: $currentLongitude, estimatedDeliveryTime: $estimatedDeliveryTime, agent: $agent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.otp, otp) || other.otp == otp) &&
            (identical(other.currentLatitude, currentLatitude) ||
                other.currentLatitude == currentLatitude) &&
            (identical(other.currentLongitude, currentLongitude) ||
                other.currentLongitude == currentLongitude) &&
            (identical(other.estimatedDeliveryTime, estimatedDeliveryTime) ||
                other.estimatedDeliveryTime == estimatedDeliveryTime) &&
            (identical(other.agent, agent) || other.agent == agent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      orderId,
      status,
      deliveryAddress,
      otp,
      currentLatitude,
      currentLongitude,
      estimatedDeliveryTime,
      agent);

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryModelImplCopyWith<_$DeliveryModelImpl> get copyWith =>
      __$$DeliveryModelImplCopyWithImpl<_$DeliveryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryModelImplToJson(
      this,
    );
  }
}

abstract class _DeliveryModel implements DeliveryModel {
  const factory _DeliveryModel(
      {required final String id,
      required final String orderId,
      required final DeliveryStatus status,
      required final String deliveryAddress,
      required final String otp,
      final double? currentLatitude,
      final double? currentLongitude,
      final DateTime? estimatedDeliveryTime,
      final DeliveryAgentModel? agent}) = _$DeliveryModelImpl;

  factory _DeliveryModel.fromJson(Map<String, dynamic> json) =
      _$DeliveryModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  DeliveryStatus get status;
  @override
  String get deliveryAddress;
  @override
  String get otp;
  @override
  double? get currentLatitude;
  @override
  double? get currentLongitude;
  @override
  DateTime? get estimatedDeliveryTime;
  @override
  DeliveryAgentModel? get agent;

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryModelImplCopyWith<_$DeliveryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
