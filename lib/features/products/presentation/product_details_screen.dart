import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buildmart_button.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/section_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../products/data/product_repository.dart';
import '../../products/data/product_model.dart';
import '../../products/data/product_providers.dart';
import '../../cart/data/cart_repository.dart';
import '../../cart/data/cart_item_model.dart';
import '../../profile/data/user_repository.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsyncValue = ref.watch(productStreamProvider(productId));

    return productAsyncValue.when(
      data: (product) => _buildScaffold(context, ref, product),
      loading: () => const Scaffold(body: SafeArea(child: ProductDetailShimmer())),
      error: (error, stack) => _buildFallbackScaffold(context, ref), // Fallback if Firebase not configured
    );
  }

  Widget _buildScaffold(BuildContext context, WidgetRef ref, ProductModel product) {
    // Add to recently viewed on build completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentlyViewedProvider.notifier).addProduct(product);
    });
    final title = product.title;
    final price = product.price;
    final originalPrice = product.originalPrice;
    final brand = product.brand;
    final imageUrl = product.imageUrl;
    final rating = product.rating;
    final reviews = product.reviews;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.background.withValues(alpha: 0.8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.accent),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.background.withValues(alpha: 0.8),
              child: IconButton(
                icon: const Icon(Icons.share, color: AppColors.accent),
                onPressed: () {
                  SharePlus.instance.share(ShareParams(text: 'Check out this amazing product: ${product.title} at BuildMart!'));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.background.withValues(alpha: 0.8),
              child: Consumer(
                builder: (context, ref, child) {
                  final isWishlist = ref.watch(wishlistProvider).contains(product.id);
                  return IconButton(
                    icon: Icon(
                      isWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isWishlist ? Colors.red : AppColors.accent,
                    ),
                    onPressed: () {
                      ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.background.withValues(alpha: 0.8),
              child: Consumer(
                builder: (context, ref, child) {
                  final userAsync = ref.watch(userProvider);
                  final userId = userAsync.value?.id;
                  if (userId == null) {
                    return IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.accent),
                      onPressed: () => context.go('/cart'),
                    );
                  }
                  final cartAsync = ref.watch(cartStreamProvider(userId));
                  final totalItems = cartAsync.when(
                    data: (items) => items.fold<int>(0, (sum, item) => sum + item.quantity),
                    loading: () => 0,
                    error: (_, __) => 0,
                  );
                  return Badge(
                    isLabelVisible: totalItems > 0,
                    label: Text('$totalItems'),
                    backgroundColor: AppColors.error,
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.accent),
                      onPressed: () => context.go('/cart'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Hero(
              tag: 'product-$title',
              child: Container(
                height: 350,
                width: double.infinity,
                color: AppColors.secondaryBackground,
                child: NetworkImageWidget(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(brand, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // Price and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('₹$price', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                              if (originalPrice != null && originalPrice > price) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '₹$originalPrice',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const Text('Inclusive of all taxes', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text('$rating ($reviews)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Attributes (Weight, Grade) - Omitted since no real data
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Compare Products Checkbox/Button
                  Consumer(
                    builder: (context, ref, child) {
                      final isComparing = ref.watch(compareProductsProvider).any((p) => p.id == product.id);
                      final compareCount = ref.watch(compareProductsProvider).length;
                      return Row(
                        children: [
                          Checkbox(
                            value: isComparing,
                            activeColor: AppColors.primary,
                            onChanged: (bool? value) {
                              if (value == true && compareCount >= 3 && !isComparing) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('You can only compare up to 3 products')),
                                );
                                return;
                              }
                              ref.read(compareProductsProvider.notifier).toggleCompare(product);
                            },
                          ),
                          Text('Add to Compare', style: Theme.of(context).textTheme.bodyMedium),
                          if (compareCount > 0) ...[
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // Navigate to compare screen (placeholder)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Compare screen coming soon')),
                                );
                              },
                              child: Text('Compare ($compareCount)'),
                            ),
                          ],
                        ],
                      );
                    }
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Related Products
                  const SectionHeader(title: 'More Products'),
                  Consumer(
                    builder: (context, ref, child) {
                      final productsAsync = ref.watch(featuredProductsProvider);
                      return productsAsync.when(
                        data: (products) {
                          // Filter related products based on keywords
                          final String lowercaseTitle = product.title.toLowerCase();
                          List<ProductModel> related = [];
                          
                          if (lowercaseTitle.contains('cement') || lowercaseTitle.contains('sand') || lowercaseTitle.contains('brick') || lowercaseTitle.contains('block')) {
                            related = products.where((p) {
                              final pt = p.title.toLowerCase();
                              return p.id != product.id && (pt.contains('cement') || pt.contains('sand') || pt.contains('brick') || pt.contains('block') || pt.contains('waterproof'));
                            }).toList();
                          } else if (lowercaseTitle.contains('pipe') || lowercaseTitle.contains('fitt') || lowercaseTitle.contains('pvc') || lowercaseTitle.contains('water') || lowercaseTitle.contains('hose')) {
                            related = products.where((p) {
                              final pt = p.title.toLowerCase();
                              return p.id != product.id && (pt.contains('pipe') || pt.contains('fitt') || pt.contains('pvc') || pt.contains('tap') || pt.contains('tank') || pt.contains('hose'));
                            }).toList();
                          } else if (lowercaseTitle.contains('steel') || lowercaseTitle.contains('bar') || lowercaseTitle.contains('tmt') || lowercaseTitle.contains('wire') || lowercaseTitle.contains('angle') || lowercaseTitle.contains('plate')) {
                            related = products.where((p) {
                              final pt = p.title.toLowerCase();
                              return p.id != product.id && (pt.contains('steel') || pt.contains('bar') || pt.contains('tmt') || pt.contains('wire') || pt.contains('aggregate') || pt.contains('cement'));
                            }).toList();
                          } else if (lowercaseTitle.contains('wood') || lowercaseTitle.contains('board') || lowercaseTitle.contains('plywood') || lowercaseTitle.contains('door')) {
                            related = products.where((p) {
                              final pt = p.title.toLowerCase();
                              return p.id != product.id && (pt.contains('wood') || pt.contains('board') || pt.contains('plywood') || pt.contains('door') || pt.contains('hardware') || pt.contains('nail') || pt.contains('screw'));
                            }).toList();
                          } else if (lowercaseTitle.contains('paint') || lowercaseTitle.contains('primer') || lowercaseTitle.contains('brush')) {
                            related = products.where((p) {
                              final pt = p.title.toLowerCase();
                              return p.id != product.id && (pt.contains('paint') || pt.contains('primer') || pt.contains('brush') || pt.contains('roller') || pt.contains('putty') || pt.contains('waterproof'));
                            }).toList();
                          } else if (lowercaseTitle.contains('tile') || lowercaseTitle.contains('stone') || lowercaseTitle.contains('granite') || lowercaseTitle.contains('marble')) {
                            related = products.where((p) {
                              final pt = p.title.toLowerCase();
                              return p.id != product.id && (pt.contains('tile') || pt.contains('stone') || pt.contains('granite') || pt.contains('marble') || pt.contains('cement') || pt.contains('grout'));
                            }).toList();
                          } else {
                            // Fallback to same brand
                            related = products.where((p) => p.id != product.id && p.brand == product.brand).toList();
                            if (related.isEmpty) {
                              related = products.where((p) => p.id != product.id).toList();
                            }
                          }
                          
                          related.shuffle();
                          
                          if (related.isEmpty) return const SizedBox();
                          
                          return SizedBox(
                            height: 320,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: related.length > 5 ? 5 : related.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final p = related[index];
                                return SizedBox(
                                  width: 180,
                                  child: ProductCard(
                                    product: p,
                                    onTap: () => context.push('/product-details/${p.id}'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => const SizedBox(),
                      );
                    }
                  ),
                  const SizedBox(height: 100), // padding for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Consumer(
        builder: (context, ref, child) {
          final userAsync = ref.watch(userProvider);
          final userId = userAsync.value?.id;
          
          // Get current quantity in cart for this product
          int currentQty = 0;
          if (userId != null) {
            final cartAsync = ref.watch(cartStreamProvider(userId));
            currentQty = cartAsync.when(
              data: (items) {
                final match = items.where((item) => item.productId == product.id);
                return match.isNotEmpty ? match.first.quantity : 0;
              },
              loading: () => 0,
              error: (_, __) => 0,
            );
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Add to Cart OR Quantity Stepper
                  Expanded(
                    child: currentQty > 0
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primary, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    currentQty == 1 ? Icons.delete_outline : Icons.remove,
                                    color: currentQty == 1 ? AppColors.error : AppColors.accent,
                                  ),
                                  onPressed: () {
                                    if (userId != null) {
                                      ref.read(cartRepositoryProvider).updateQuantity(
                                        userId, product.id, currentQty - 1,
                                      );
                                    }
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$currentQty',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: AppColors.accent),
                                  onPressed: () {
                                    if (userId != null) {
                                      ref.read(cartRepositoryProvider).updateQuantity(
                                        userId, product.id, currentQty + 1,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          )
                        : BuildMartButton(
                            text: 'Add to Cart',
                            isOutlined: true,
                            onPressed: () async {
                              if (userId != null) {
                                final item = CartItemModel(
                                  id: product.id,
                                  productId: product.id,
                                  title: product.title,
                                  brand: product.brand,
                                  price: product.price,
                                  imageUrl: product.imageUrl,
                                  quantity: 1,
                                  shopName: product.brand,
                                );
                                await ref.read(cartRepositoryProvider).addToCart(userId, item);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${product.title} added to cart')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please login to add to cart')),
                                );
                              }
                            },
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BuildMartButton(
                      text: 'Buy Now',
                      onPressed: () => context.push('/checkout'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildFallbackScaffold(BuildContext context, WidgetRef ref) {
    // This provides a fallback UI to ensure the app continues to render if the database connection fails or is absent.
    const product = ProductModel(
      id: 'fallback_1',
      title: 'UltraTech Super Cement 50kg',
      brand: 'UltraTech',
      price: 380.0,
      originalPrice: 420.0,
      imageUrl: 'https://via.placeholder.com/400',
      rating: 4.8,
      reviews: 245,
    );
    return _buildScaffold(context, ref, product);
  }
}
