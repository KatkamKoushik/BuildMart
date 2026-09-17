import 'package:flutter/material.dart' hide CarouselController;
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/shop_card.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/network_image_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/data/product_repository.dart';
import '../../products/data/product_providers.dart';
import '../../search/presentation/advanced_search_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/banner_providers.dart';
import '../../profile/data/user_repository.dart';
import '../../categories/data/category_repository.dart';
import '../../brands/data/brand_repository.dart';
import '../../shops/data/shop_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../checkout/presentation/checkout_providers.dart';
import '../../../core/services/seeder_service.dart';
import '../../../core/utils/category_translator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
        onRefresh: () async {
          // Simulate network delay for pull-to-refresh
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Sticky Search Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySearchBarDelegate(
                child: const AdvancedSearchBar(),
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  _buildBannerSlider(ref),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildCategoriesGrid(context, ref),
                        SectionHeader(
                          title: AppLocalizations.of(context)!.popularBrands,
                          onSeeAll: () => context.push('/brands'),
                        ),
                        _buildBrandsHorizontalList(ref).animate().fade(delay: 200.ms).slideX(),

                        Consumer(
                          builder: (context, ref, child) {
                            final recentlyViewed = ref.watch(recentlyViewedProvider);
                            if (recentlyViewed.isEmpty) return const SizedBox.shrink();
                            
                            return Column(
                              children: [
                                SectionHeader(
                                  title: AppLocalizations.of(context)!.recentlyViewed,
                                  onSeeAll: () => context.push('/products'),
                                ),
                                SizedBox(
                                  height: 360,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: recentlyViewed.length,
                                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                                    itemBuilder: (context, index) {
                                      final product = recentlyViewed[index];
                                      return SizedBox(
                                        width: 180,
                                        child: ProductCard(
                                          product: product,
                                          onTap: () => context.push('/product-details/${product.id}'),
                                        ),
                                      );
                                    },
                                  ),
                                ).animate().fade(delay: 350.ms).slideY(),
                              ],
                            );
                          },
                        ),
                        SectionHeader(
                          title: AppLocalizations.of(context)!.trendingProducts,
                          onSeeAll: () => context.push('/products'),
                        ),
                        _buildProductsHorizontalList(context, ref).animate().fade(delay: 400.ms).slideY(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SectionHeader(
                    title: AppLocalizations.of(context)!.nearbyShops,
                    onSeeAll: () => context.push('/shops'),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final shopsAsync = ref.watch(nearbyShopsProvider);
                      return shopsAsync.when(
                        data: (shops) {
                          if (shops.isEmpty) return const SizedBox.shrink();
                          final displayShops = shops.take(3).toList();
                          return Column(
                            children: displayShops.map((shop) => ShopCard(
                              shop: shop,
                              onTap: () => context.push('/shop/${shop.id}'),
                            )).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => const SizedBox.shrink(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ).animate().fade(delay: 500.ms).slideY(),
            ),
          )
        ],
      ),
      ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    
    String titleText = AppLocalizations.of(context)!.location;
    String shortAddress = AppLocalizations.of(context)!.selectDeliveryLocation;
    
    userAsync.whenData((user) {
      if (user != null && user.savedAddresses.isNotEmpty) {
        final addressLine = user.savedAddresses.first;
        final parts = addressLine.split(',');
        shortAddress = parts.isNotEmpty ? parts[0].trim() : addressLine;
        titleText = AppLocalizations.of(context)!.homeLocation;
      }
    });

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: Semantics(
        label: 'Current Delivery Location: $shortAddress',
        button: true,
        child: GestureDetector(
          onTap: () => context.push('/location'),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.deliveringTo(titleText), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textLight)),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            shortAddress,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Semantics(
          label: 'Seed Database',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.cloud_upload, color: AppColors.primary, size: 28),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeding database...')));
              await SeederService().seedDatabase();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeding complete! Please restart app.')));
              }
            },
          ),
        ),
        Semantics(
          label: 'Notifications',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.accent, size: 28),
            onPressed: () => context.push('/notifications'),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBannerSlider(WidgetRef ref) {
    final bannersAsync = ref.watch(bannersProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox(height: 180);
        return CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.92,
            aspectRatio: 2.0,
            initialPage: 0,
            autoPlayInterval: const Duration(seconds: 4),
          ),
          itemBuilder: (context, index, realIndex) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: NetworkImageWidget(
                  imageUrl: banners[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            );
          },
        ).animate().fade(duration: 500.ms).scale(duration: 500.ms);
      },
      loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
      error: (e, st) => const SizedBox(height: 180, child: Center(child: Text('Error loading banners'))),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox();
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = screenWidth > 600 ? 6 : 4;
        
        // Take at most 8 categories for the home screen grid
        final displayCategories = categories.take(8).toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCategories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final category = displayCategories[index];
            return Semantics(
              label: 'Category: ${category.name}',
              button: true,
              child: GestureDetector(
                onTap: () => context.push('/products?categoryId=${category.id}'),
                child: Column(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: NetworkImageWidget(
                          imageUrl: category.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      translateCategory(context, category.name),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ).animate().scale(delay: (index * 50).ms, duration: 300.ms).fadeIn();
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Error loading categories')),
    );
  }

  Widget _buildBrandsHorizontalList(WidgetRef ref) {
    final brandsAsync = ref.watch(brandsProvider);

    return brandsAsync.when(
      data: (brands) {
        if (brands.isEmpty) return const SizedBox();
        return SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return GestureDetector(
                onTap: () {
                  // We need context to be accessible here, ListView.builder has it.
                  // Wait, context is the inner context from itemBuilder, which is perfect.
                  context.push('/products?brandId=${brand.id}');
                },
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NetworkImageWidget(
                      imageUrl: brand.logoUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
      error: (e, st) => const SizedBox(height: 80, child: Center(child: Text('Error loading brands'))),
    );
  }

  Widget _buildProductsHorizontalList(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(featuredProductsProvider);

    return SizedBox(
      height: 360,
      child: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No Products',
              message: 'Check back later for new arrivals.',
            );
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 180,
                child: ProductCard(
                  product: product,
                  onTap: () => context.push('/product-details/${product.id}'),
                ),
              );
            },
          );
        },
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) => const ProductCardShimmer(),
        ),
        error: (error, stack) {
          return const Center(child: Text('Error loading featured products'));
        },
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  double get maxExtent => 90.0;

  @override
  double get minExtent => 90.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
