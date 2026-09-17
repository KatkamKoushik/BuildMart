import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../orders/data/order_repository.dart';
import '../../profile/data/user_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/buildmart_card.dart';
import '../../../shared/widgets/buildmart_button.dart';
import '../../../shared/widgets/shimmer_loader.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final userId = userState.value?.id;
    
    // If not logged in, just show empty
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Please log in',
          message: 'You need to be logged in to view your orders.',
          buttonText: 'Login',
          onAction: () {
            context.go('/login');
          },
        ),
      );
    }
    
    final ordersAsync = ref.watch(userOrdersProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'You haven\'t placed any orders yet. Once you do, they\'ll appear here.',
              buttonText: 'Start Shopping',
              onAction: () => context.go('/home'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: BuildMartCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Order #${order.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Status: ${order.status}\nTotal: ₹${order.totalAmount}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/order-tracking');
                        },
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading Invoice...')));
                              },
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Invoice'),
                              style: TextButton.styleFrom(foregroundColor: AppColors.textLight),
                            ),
                            BuildMartButton(
                              text: 'Repeat Order',
                              isOutlined: true,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Items added to cart')));
                                context.go('/cart');
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, __) => const OrderCardShimmer(),
        ),
        error: (error, stack) => const Center(child: Text('Failed to load orders')),
      ),
    );
  }
}
