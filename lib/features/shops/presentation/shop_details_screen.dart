import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/buildmart_card.dart';
import '../../shops/data/shop_providers.dart';
import '../../products/data/product_repository.dart';

class ShopDetailsScreen extends ConsumerWidget {
  const ShopDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const shopId = 'shop_123';
    final isFavorite = ref.watch(favoriteShopsProvider).contains(shopId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Sri Sai Hardware & Cements',
                  style: TextStyle(
                      color: AppColors.background,
                      textBaseline: TextBaseline.alphabetic,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
              background: NetworkImageWidget(
                imageUrl: 'https://via.placeholder.com/600x300',
                fit: BoxFit.cover,
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.background),
            actions: [
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : null),
                onPressed: () {
                  ref
                      .read(favoriteShopsProvider.notifier)
                      .toggleFavorite(shopId);
                },
              ),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata row
                  BuildMartCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMetaItem(Icons.star, '4.8 (120)', 'Ratings'),
                            _buildMetaItem(
                                Icons.location_on, '1.2 km', 'Distance'),
                            _buildMetaItem(
                                Icons.access_time, '8AM - 8PM', 'Open Hours'),
                          ],
                        ),
                        const Divider(height: 24),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('GSTIN: 36ABCDE1234F1Z5',
                                style: TextStyle(
                                    color: AppColors.textLight, fontSize: 12)),
                            Text('Verified Partner',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact & Directions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.call),
                          label: const Text('Contact'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Products Section
                  const SectionHeader(title: 'Available Products'),
                  Consumer(
                    builder: (context, ref, child) {
                      final productsAsync = ref.watch(featuredProductsProvider);
                      return productsAsync.when(
                        data: (products) {
                          if (products.isEmpty)
                            return const Text('No products available');
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.55,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final p = products[index];
                              return ProductCard(
                                product: p,
                                onTap: () =>
                                    context.push('/product-details/${p.id}'),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, st) => const Text('Error loading products'),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
      ],
    );
  }
}
