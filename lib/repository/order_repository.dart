import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';
import '../models/order_model.dart';
import '../core/error/failures.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(FirebaseFirestore.instance, ref.read(cacheServiceProvider));
});

class OrderRepository {
  final FirebaseFirestore _firestore;
  final CacheService _cacheService;

  OrderRepository(this._firestore, this._cacheService);

  Future<OrderModel> getOrderById(String orderId) async {
    final cacheKey = 'order_$orderId';
    
    // Check Cache
    final cachedData = _cacheService.readData(_cacheService.ordersBox, cacheKey);
    if (cachedData != null) {
      try {
        return OrderModel.fromJson(jsonDecode(cachedData));
      } catch (e) {
        // Fallback
      }
    }

    // Network Request
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        final order = OrderModel.fromJson(data);
        
        // Update Cache
        await _cacheService.writeData(
          _cacheService.ordersBox, 
          cacheKey, 
          jsonEncode(data),
        );
        
        return order;
      } else {
        throw const ServerFailure('Failed to fetch order');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Read all products to check stock
        final Map<String, DocumentSnapshot> productDocs = {};
        for (final group in order.shopGroups) {
          for (final item in group.items) {
            final docRef = _firestore.collection('products').doc(item.product.id);
            final docSnapshot = await transaction.get(docRef);
            if (!docSnapshot.exists) {
              throw ServerFailure('Product ${item.product.name} no longer exists');
            }
            productDocs[item.product.id] = docSnapshot;
          }
        }

        // 2. Verify stock
        for (final group in order.shopGroups) {
          for (final item in group.items) {
            final docData = productDocs[item.product.id]!.data() as Map<String, dynamic>;
            final currentStock = (docData['stockQuantity'] as num?)?.toInt() ?? 0;
            
            if (currentStock < item.quantity) {
              throw ServerFailure('Not enough stock for ${item.product.name}');
            }
          }
        }

        // 3. Decrement stock
        for (final group in order.shopGroups) {
          for (final item in group.items) {
            final docRef = _firestore.collection('products').doc(item.product.id);
            final docData = productDocs[item.product.id]!.data() as Map<String, dynamic>;
            final currentStock = (docData['stockQuantity'] as num?)?.toInt() ?? 0;
            
            transaction.update(docRef, {
              'stockQuantity': currentStock - item.quantity,
              'inStock': (currentStock - item.quantity) > 0,
            });
          }
        }

        // 4. Create Order
        final orderRef = _firestore.collection('orders').doc(order.id);
        transaction.set(orderRef, order.toJson());
      });

      // Save locally to reflect immediately
      await _cacheService.writeData(
        _cacheService.ordersBox, 
        'order_${order.id}', 
        jsonEncode(order.toJson()),
      );
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(e.toString());
    }
  }
}
