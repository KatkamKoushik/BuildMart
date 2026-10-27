import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'network_image_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/products/data/product_model.dart';
import '../../features/products/data/product_providers.dart';
import '../../features/profile/data/user_repository.dart';
import '../../features/cart/data/cart_repository.dart';
import '../../features/cart/data/cart_item_model.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discount = (product.originalPrice != null &&
            product.originalPrice! > product.price)
        ? ((product.originalPrice! - product.price) /
                product.originalPrice! *
                100)
            .round()
        : 0;
    final theme = Theme.of(context);
    final isWishlist = ref.watch(wishlistProvider).contains(product.id);

    int cartQuantity = 0;
    final userState = ref.watch(userProvider);
    final userId = userState.value?.id;
    if (userId != null) {
      final cartAsync = ref.watch(cartStreamProvider(userId));
      if (cartAsync.value != null) {
        for (var item in cartAsync.value!) {
          if (item.productId == product.id) {
            cartQuantity = item.quantity;
            break;
          }
        }
      }
    }

    return Semantics(
      label:
          'Product: ${product.title}, Price: ₹${product.price}, ${product.inStock ? 'In Stock' : 'Out of Stock'}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image & Badges
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Container(
                        width: double.infinity,
                        color: theme.colorScheme.surface,
                        child: NetworkImageWidget(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (discount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Semantics(
                        label: isWishlist
                            ? 'Remove from Wishlist'
                            : 'Add to Wishlist',
                        button: true,
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(wishlistProvider.notifier)
                                .toggleWishlist(product.id);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: CircleAvatar(
                            backgroundColor: theme.colorScheme.surface
                                .withValues(alpha: 0.9),
                            radius: 16,
                            child: Icon(
                              isWishlist
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: isWishlist
                                  ? AppColors.error
                                  : AppColors.textLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    if (discount > 0)
                      Text(
                        '₹${product.originalPrice!.toStringAsFixed(0)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          decoration: TextDecoration.lineThrough,
                          decorationColor:
                              theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        cartQuantity > 0 && userId != null
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primary),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => ref
                                          .read(cartRepositoryProvider)
                                          .updateQuantity(userId, product.id,
                                              cartQuantity - 1),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 6),
                                        child: Icon(Icons.remove,
                                            size: 16, color: AppColors.primary),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      child: Text('$cartQuantity',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                    InkWell(
                                      onTap: () => ref
                                          .read(cartRepositoryProvider)
                                          .updateQuantity(userId, product.id,
                                              cartQuantity + 1),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 6),
                                        child: Icon(Icons.add,
                                            size: 16, color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Semantics(
                                label: 'Add to Cart',
                                button: true,
                                child: InkWell(
                                  onTap: product.inStock
                                      ? () async {
                                          final userAsync =
                                              ref.read(userProvider);
                                          if (userAsync.value != null) {
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
                                                .addToCart(
                                                    userAsync.value!.id, item);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          '${product.title} added to cart')));
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Please login to add to cart')));
                                          }
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: product.inStock
                                          ? AppColors.primary
                                          : AppColors.border,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      color: product.inStock
                                          ? AppColors.accent
                                          : AppColors.textLight,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.inStock
                          ? AppLocalizations.of(context)!.inStock
                          : 'Out of Stock',
                      style: TextStyle(
                        color: product.inStock
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(duration: 300.ms, curve: Curves.easeOut);
  }
}
