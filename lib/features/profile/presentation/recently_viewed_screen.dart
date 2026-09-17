import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../products/data/product_providers.dart';
import '../../products/data/product_model.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../core/constants/app_colors.dart';

class RecentlyViewedScreen extends ConsumerWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(recentlyViewedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Viewed'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text(
                    'No recently viewed items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Items you view will appear here.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Explore Products'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final product = history[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    context.push('/product-details/${product.id}');
                  },
                );
              },
            ),
    );
  }
}
