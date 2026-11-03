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
      loading: () =>
          const Scaffold(body: SafeArea(child: ProductDetailShimmer())),
      error: (error, stack) => _buildErrorScaffold(context),
    );
  }

  Widget _buildScaffold(
      BuildContext context, WidgetRef ref, ProductModel product) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        (isDark ? AppColors.darkSecondaryBackground : AppColors.background)
            .withValues(alpha: 0.85);
    final iconColor = isDark ? AppColors.darkText : AppColors.accent;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: surfaceColor,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: CircleAvatar(
              backgroundColor: surfaceColor,
              child: IconButton(
                icon: Icon(Icons.share, color: iconColor),
                onPressed: () {
                  SharePlus.instance.share(ShareParams(
                      text:
                          'Check out this amazing product: ${product.title} at BuildMart!'));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: CircleAvatar(
              backgroundColor: surfaceColor,
              child: Consumer(
                builder: (context, ref, child) {
                  final isWishlist =
                      ref.watch(wishlistProvider).contains(product.id);
                  return IconButton(
                    icon: Icon(
                      isWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isWishlist ? Colors.red : iconColor,
                    ),
                    onPressed: () {
                      ref
                          .read(wishlistProvider.notifier)
                          .toggleWishlist(product.id);
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: CircleAvatar(
              backgroundColor: surfaceColor,
              child: Consumer(
                builder: (context, ref, child) {
                  final userAsync = ref.watch(userProvider);
                  final userId = userAsync.value?.id ?? 'usr_buyer_backend';
                  final cartAsync = ref.watch(cartStreamProvider(userId));
                  final totalItems = cartAsync.when(
                    data: (items) =>
                        items.fold<int>(0, (sum, item) => sum + item.quantity),
                    loading: () => 0,
                    error: (_, __) => 0,
                  );
                  return Badge(
                    isLabelVisible: totalItems > 0,
                    label: Text('$totalItems'),
                    backgroundColor: AppColors.error,
                    child: IconButton(
                      icon:
                          Icon(Icons.shopping_cart_outlined, color: iconColor),
                      onPressed: () => context.push('/cart'),
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
                color: isDark
                    ? AppColors.darkSecondaryBackground
                    : AppColors.secondaryBackground,
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
                  Text(brand,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('₹$price',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      )),
                              if (originalPrice != null &&
                                  originalPrice > price) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '₹$originalPrice',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        color: AppColors.textLight,
                                      ),
                                ),
                              ],
                            ],
                          ),
                          const Text('Inclusive of all taxes',
                              style: TextStyle(
                                  color: AppColors.textLight, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSecondaryBackground
                              : AppColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text('$rating ($reviews)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.text,
                                    )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Compare Products Checkbox/Button
                  Consumer(builder: (context, ref, child) {
                    final isComparing = ref
                        .watch(compareProductsProvider)
                        .any((p) => p.id == product.id);
                    final compareCount =
                        ref.watch(compareProductsProvider).length;
                    return Row(
                      children: [
                        Checkbox(
                          value: isComparing,
                          activeColor: AppColors.primary,
                          onChanged: (bool? value) {
                            if (value == true &&
                                compareCount >= 3 &&
                                !isComparing) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'You can only compare up to 3 products')),
                              );
                              return;
                            }
                            ref
                                .read(compareProductsProvider.notifier)
                                .toggleCompare(product);
                          },
                        ),
                        Text('Add to Compare',
                            style: Theme.of(context).textTheme.bodyMedium),
                        if (compareCount > 0) ...[
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Compare screen coming soon')),
                              );
                            },
                            child: Text('Compare ($compareCount)'),
                          ),
                        ],
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  // Related Products
                  const SectionHeader(title: 'More Products'),
                  Consumer(builder: (context, ref, child) {
                    final productsAsync = ref.watch(featuredProductsProvider);
                    return productsAsync.when(
                      data: (products) {
                        // Filter related products based on keywords
                        final String lowercaseTitle =
                            product.title.toLowerCase();
                        List<ProductModel> related = [];

                        if (lowercaseTitle.contains('cement') ||
                            lowercaseTitle.contains('concrete')) {
                          related = products.where((p) {
                            final pt = p.title.toLowerCase();
                            return p.id != product.id &&
                                (pt.contains('cement') ||
                                    pt.contains('sand') ||
                                    pt.contains('brick') ||
                                    pt.contains('block') ||
                                    pt.contains('aggregate'));
                          }).toList();
                        } else if (lowercaseTitle.contains('steel') ||
                            lowercaseTitle.contains('iron') ||
                            lowercaseTitle.contains('rod') ||
                            lowercaseTitle.contains('tmt')) {
                          related = products.where((p) {
                            final pt = p.title.toLowerCase();
                            return p.id != product.id &&
                                (pt.contains('steel') ||
                                    pt.contains('rod') ||
                                    pt.contains('wire') ||
                                    pt.contains('bar') ||
                                    pt.contains('mesh'));
                          }).toList();
                        } else if (lowercaseTitle.contains('pipe') ||
                            lowercaseTitle.contains('plumb') ||
                            lowercaseTitle.contains('tap') ||
                            lowercaseTitle.contains('faucet')) {
                          related = products.where((p) {
                            final pt = p.title.toLowerCase();
                            return p.id != product.id &&
                                (pt.contains('pipe') ||
                                    pt.contains('plumb') ||
                                    pt.contains('tap') ||
                                    pt.contains('valve') ||
                                    pt.contains('tank'));
                          }).toList();
                        } else if (lowercaseTitle.contains('wire') ||
                            lowercaseTitle.contains('cable') ||
                            lowercaseTitle.contains('switch') ||
                            lowercaseTitle.contains('electric')) {
                          related = products.where((p) {
                            final pt = p.title.toLowerCase();
                            return p.id != product.id &&
                                (pt.contains('wire') ||
                                    pt.contains('switch') ||
                                    pt.contains('light') ||
                                    pt.contains('mcb') ||
                                    pt.contains('cable'));
                          }).toList();
                        } else if (lowercaseTitle.contains('wood') ||
                            lowercaseTitle.contains('plywood') ||
                            lowercaseTitle.contains('timber') ||
                            lowercaseTitle.contains('board')) {
                          related = products.where((p) {
                            final pt = p.title.toLowerCase();
                            return p.id != product.id &&
                                (pt.contains('wood') ||
                                    pt.contains('board') ||
                                    pt.contains('plywood') ||
                                    pt.contains('door') ||
                                    pt.contains('hardware') ||
                                    pt.contains('nail') ||
                                    pt.contains('screw'));
                          }).toList();
                        } else if (lowercaseTitle.contains('paint') ||
                            lowercaseTitle.contains('primer') ||
                            lowercaseTitle.contains('brush')) {
                          related = products.where((p) {
                            final pt = p.title.toLowerCase();
                            return p.id != product.id &&
                                (pt.contains('paint') ||
                                    pt.contains('primer') ||
                                    pt.contains('brush') ||
                                    pt.contains('roller') ||
                                    pt.contains('putty') ||
                                    pt.contains('waterproof'));
                          }).toList();
                        } else if (lowercaseTitle.contains('tile') ||
                            lowercaseTitle.contains('stone') ||
                            lowercaseTitle.contains('granite') ||
                            lowercaseTitle.contains('marble')) {
                          related = products.where((p) {
                            final pt = p.title.toLowerCase();
                            return p.id != product.id &&
                                (pt.contains('tile') ||
                                    pt.contains('stone') ||
                                    pt.contains('granite') ||
                                    pt.contains('marble') ||
                                    pt.contains('cement') ||
                                    pt.contains('grout'));
                          }).toList();
                        } else {
                          // Fallback to same brand
                          related = products
                              .where((p) =>
                                  p.id != product.id &&
                                  p.brand == product.brand)
                              .toList();
                          if (related.isEmpty) {
                            related = products
                                .where((p) => p.id != product.id)
                                .toList();
                          }
                        }

                        related.shuffle();

                        if (related.isEmpty) return const SizedBox();

                        return SizedBox(
                          height: 320,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: related.length > 5 ? 5 : related.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final p = related[index];
                              return SizedBox(
                                width: 180,
                                child: ProductCard(
                                  product: p,
                                  onTap: () =>
                                      context.push('/product-details/${p.id}'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => const SizedBox(),
                    );
                  }),
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
          final userId = userAsync.value?.id ?? 'usr_buyer_backend';
          final isDark = Theme.of(context).brightness == Brightness.dark;

          // Get current quantity in cart for this product
          final cartAsync = ref.watch(cartStreamProvider(userId));
          final currentQty = cartAsync.when(
            data: (items) {
              final match = items.where((item) => item.productId == product.id);
              return match.isNotEmpty ? match.first.quantity : 0;
            },
            loading: () => 0,
            error: (_, __) => 0,
          );

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.background,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black54
                      : AppColors.accent.withValues(alpha: 0.05),
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
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    currentQty == 1
                                        ? Icons.delete_outline
                                        : Icons.remove,
                                    color: currentQty == 1
                                        ? AppColors.error
                                        : (isDark
                                            ? AppColors.darkText
                                            : AppColors.accent),
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(cartRepositoryProvider)
                                        .updateQuantity(
                                          userId,
                                          product.id,
                                          currentQty - 1,
                                        );
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$currentQty',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.darkText
                                              : AppColors.accent,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.accent),
                                  onPressed: () {
                                    ref
                                        .read(cartRepositoryProvider)
                                        .updateQuantity(
                                          userId,
                                          product.id,
                                          currentQty + 1,
                                        );
                                  },
                                ),
                              ],
                            ),
                          )
                        : BuildMartButton(
                            text: 'Add to Cart',
                            isOutlined: true,
                            onPressed: () async {
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
                              await ref
                                  .read(cartRepositoryProvider)
                                  .addToCart(userId, item);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${product.title} added to cart')),
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

  Widget _buildErrorScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text(
                'Product Not Found',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The product you are looking for is currently unavailable.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 24),
              BuildMartButton(
                text: 'Browse Products',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
