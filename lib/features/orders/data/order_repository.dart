import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildmart/features/orders/data/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(FirebaseFirestore.instance);
});

final orderStreamProvider = StreamProvider.family<OrderModel, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchOrder(orderId);
});

final userOrdersProvider = StreamProvider.family<List<OrderModel>, String>((ref, userId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchUserOrders(userId);
});

class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository(this._firestore);

  Stream<OrderModel> watchOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw Exception('Order not found in Firestore');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      // Convert Timestamp to DateTime if present
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      return OrderModel.fromJson(data);
    });
  }
  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        // Removed .orderBy('createdAt', descending: true) to avoid requiring a composite index
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return OrderModel.fromJson(data);
      }).toList();
      
      // Sort in memory instead
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }
}
