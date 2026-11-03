import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/buildmart_card.dart';
import '../../shops/data/shop_providers.dart';
import '../../shops/data/shop_repository.dart';
import '../../products/data/product_repository.dart';

class ShopDetailsScreen extends ConsumerWidget {
  final String shopId;
  const ShopDetailsScreen({super.key, this.shopId = 'shop_001'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteShopsProvider).contains(shopId);
    final shopAsync = ref.watch(shopByIdProvider(shopId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return shopAsync.when(
      data: (shop) {
        final shopName = shop?.name ?? 'Shop Details';
        final coverImage = shop?.coverImageUrl ?? '';
        final rating = shop?.rating ?? 4.5;
        final reviewCount = shop?.reviewCount ?? 0;
        final distance = shop?.distance ?? '1.5 km';
        final address = shop?.address ?? '';

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    shopName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                            color: Colors.black87,
                            blurRadius: 6,
                            offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetworkImageWidget(
                        imageUrl: coverImage,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.error : Colors.white,
                    ),
                    onPressed: () {
                      ref
                          .read(favoriteShopsProvider.notifier)
                          .toggleFavorite(shopId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BuildMartCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildMetaItem(context, Icons.star,
                                    '$rating ($reviewCount)', 'Ratings'),
                                _buildMetaItem(context, Icons.location_on,
                                    distance, 'Distance'),
                                _buildMetaItem(context, Icons.access_time,
                                    '8 AM - 8 PM', 'Hours'),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    address.isNotEmpty
                                        ? address
                                        : 'Verified Building Materials Yard',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextLight
                                          : AppColors.textLight,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Verified Partner',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Categories available in this shop
                      if (shop != null && shop.categories.isNotEmpty) ...[
                        Text(
                          'Available Categories',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: shop.categories.map((cat) {
                            return Chip(
                              label: Text(cat),
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              labelStyle: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      SectionHeader(
                        title: 'Products in Store',
                        onSeeAll: () => context.push('/products'),
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final productsAsync =
                              ref.watch(featuredProductsProvider);
                          return productsAsync.when(
                            data: (products) {
                              final shopProducts = products.take(6).toList();
                              if (shopProducts.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                        'No products available for this shop.'),
                                  ),
                                );
                              }
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: shopProducts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.72,
                                ),
                                itemBuilder: (context, index) {
                                  final p = shopProducts[index];
                                  return ProductCard(
                                    product: p,
                                    onTap: () => context
                                        .push('/product-details/${p.id}'),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Shop Details')),
        body: const Center(child: Text('Failed to load shop details.')),
      ),
    );
  }

  Widget _buildMetaItem(
      BuildContext context, IconData icon, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextLight : AppColors.textLight,
              ),
        ),
      ],
    );
  }
}
