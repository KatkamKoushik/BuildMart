import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../products/data/product_providers.dart';
import '../../products/data/product_model.dart';
import '../../products/data/product_repository.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../core/constants/app_colors.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Save items you like here to buy them later.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Start Shopping'),
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
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final productId = wishlist.elementAt(index);
                // We need to fetch the product. Let's use a Consumer to watch the stream
                return Consumer(
                  builder: (context, ref, child) {
                    final productAsync = ref.watch(productStreamProvider(productId));
                    return productAsync.when(
                      data: (product) => ProductCard(
                        product: product,
                        onTap: () => context.push('/product-details/${product.id}'),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => const SizedBox(),
                    );
                  }
                );
              },
            ),
    );
  }
}
