import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildmart/features/orders/data/order_model.dart';
import '../../../core/services/api_client.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(FirebaseFirestore.instance);
});

final orderStreamProvider =
    StreamProvider.family<OrderModel, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchOrder(orderId);
});

final userOrdersProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, userId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchUserOrders(userId);
});

class OrderRepository {
  final FirebaseFirestore _firestore;
  final ApiClient _apiClient = ApiClient();

  OrderRepository(this._firestore);

  OrderModel _mapBackendOrder(Map<String, dynamic> data) {
    final id = data['id']?.toString() ?? '';
    final status = data['status']?.toString() ?? 'placed';
    final total = (data['total_amount'] ?? data['totalAmount'] ?? 0.0).toDouble();
    final rawDate = data['created_at'] ?? data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (rawDate != null) {
      if (rawDate is String) {
        createdAt = DateTime.tryParse(rawDate) ?? DateTime.now();
      }
    }
    return OrderModel(
      id: id,
      status: status,
      totalAmount: total,
      createdAt: createdAt,
      driverName: data['driver_name']?.toString() ?? data['driverName']?.toString() ?? '',
      driverPhone: data['driver_phone']?.toString() ?? data['driverPhone']?.toString() ?? '',
    );
  }

  Stream<OrderModel> watchOrder(String orderId) async* {
    // 1. Try backend API
    try {
      final res = await _apiClient.get('/orders/$orderId', auth: true);
      if (res is Map<String, dynamic>) {
        yield _mapBackendOrder(res);
      }
    } catch (e) {
      debugPrint('[OrderRepository] Backend watchOrder notice: $e');
    }

    // 2. Stream from Cloud Firestore
    try {
      yield* _firestore.collection('orders').doc(orderId).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) {
          throw Exception('Order not found');
        }
        final data = doc.data()!;
        data['id'] = doc.id;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return OrderModel.fromJson(data);
      }).handleError((error) {
        debugPrint('[OrderRepository] Firestore order stream error: $error');
        throw error;
      });
    } catch (e) {
      debugPrint('[OrderRepository] Firestore watchOrder error: $e');
    }
  }

  Stream<List<OrderModel>> watchUserOrders(String userId) async* {
    // Initial emission of real empty list if nothing cached
    yield const <OrderModel>[];

    // 1. Check Backend API for real user orders
    try {
      final res = await _apiClient.get('/orders', auth: true);
      if (res is List && res.isNotEmpty) {
        final apiOrders = res
            .map((item) => _mapBackendOrder(Map<String, dynamic>.from(item as Map)))
            .toList();
        apiOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        yield apiOrders;
      }
    } catch (e) {
      debugPrint('[OrderRepository] Backend API orders notice: $e');
    }

    // 2. Stream from Cloud Firestore
    try {
      yield* _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final orders = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          if (data['createdAt'] is Timestamp) {
            data['createdAt'] =
                (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          return OrderModel.fromJson(data);
        }).toList();

        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      }).handleError((error) {
        debugPrint('[OrderRepository] Firestore orders error: $error');
        return const <OrderModel>[];
      });
    } catch (e) {
      debugPrint('[OrderRepository] Firestore watchUserOrders error: $e');
      yield const <OrderModel>[];
    }
  }
}
