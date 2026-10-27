import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/network_image_widget.dart';
import '../../../shared/widgets/buildmart_card.dart';
import '../../../shared/widgets/buildmart_button.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../cart/data/cart_repository.dart';
import '../../cart/data/cart_item_model.dart';
import '../../cart/data/cart_providers.dart';
import '../../profile/data/user_repository.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userId = userState.value?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.myCart),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              }),
        ),
        body: EmptyState(
          icon: Icons.person_outline,
          title: 'Not logged in',
          message: 'Please sign in to view your cart.',
          buttonText: 'Login',
          onAction: () {
            context.go('/login');
          },
        ),
      );
    }

    final cartAsync = ref.watch(cartStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myCart),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            }),
      ),
      body: cartAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message:
                  'Looks like you haven\'t added any products to your cart yet.',
              buttonText: 'Start Shopping',
              onAction: () => context.go('/home'),
            );
          }

          // Shop-wise Grouping
          final groupedItems = <String, List<CartItemModel>>{};
          for (var item in items) {
            String displayShopName = item.shopName;
            if (displayShopName == 'Unknown Shop' || displayShopName.isEmpty) {
              displayShopName = item.brand;
            }

            // Format if it matches the raw brand id (which are usually lowercase like "jaquar")
            if (displayShopName == item.brand && displayShopName.isNotEmpty) {
              displayShopName =
                  '${displayShopName[0].toUpperCase()}${displayShopName.substring(1)} Store';
            }

            groupedItems.putIfAbsent(displayShopName, () => []).add(item);
          }

          final savedForLater = ref.watch(saveForLaterProvider);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...groupedItems.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildShopGroup(
                            context, ref, entry.key, entry.value, userId),
                      );
                    }),
                    if (savedForLater.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                          '${AppLocalizations.of(context)!.saveForLater} (${savedForLater.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildSavedForLaterList(context, ref, savedForLater),
                    ],
                  ],
                ),
              ),
              _buildCheckoutSummary(context, ref, items),
            ],
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, __) => const CartItemShimmer(),
        ),
        error: (error, stack) => Center(
          child: Text('Failed to load cart: $error'),
        ),
      ),
    );
  }

  Widget _buildShopGroup(BuildContext context, WidgetRef ref, String shopName,
      List<CartItemModel> items, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.storefront, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(shopName,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: BuildMartCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: NetworkImageWidget(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                              '₹${NumberFormat('#,##,###.##', 'en_US').format(item.price)} / unit',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textLight)),
                        ],
                      ),
                    ),

                    // Actions (Qty + Save)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            _buildQtyBtn(
                                context, Icons.remove, 'Decrease quantity', () {
                              ref.read(cartRepositoryProvider).updateQuantity(
                                  userId, item.id, item.quantity - 1);
                            }),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('${item.quantity}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                            _buildQtyBtn(
                                context, Icons.add, 'Increase quantity', () {
                              ref.read(cartRepositoryProvider).updateQuantity(
                                  userId, item.id, item.quantity + 1);
                            }),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            ref
                                .read(saveForLaterProvider.notifier)
                                .saveForLater(item);
                            // Also remove from cart
                            ref
                                .read(cartRepositoryProvider)
                                .updateQuantity(userId, item.id, 0);
                          },
                          icon: const Icon(Icons.bookmark_border, size: 18),
                          label:
                              Text(AppLocalizations.of(context)!.saveForLater),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildQtyBtn(BuildContext context, IconData icon, String semanticLabel,
      VoidCallback onTap) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12), // Increased for 48px touch target
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget _buildSavedForLaterList(
      BuildContext context, WidgetRef ref, List<CartItemModel> items) {
    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: BuildMartCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: NetworkImageWidget(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                                '₹${NumberFormat('#,##,###.##', 'en_US').format(item.price)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textLight)),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ref
                              .read(saveForLaterProvider.notifier)
                              .moveToCart(item);
                          // Add back to cart

                          final userState = ref.read(userProvider);
                          final uId = userState.value?.id;
                          if (uId != null) {
                            ref
                                .read(cartRepositoryProvider)
                                .updateQuantity(uId, item.id, 1);
                          }
                        },
                        icon: const Icon(Icons.shopping_cart, size: 18),
                        label: const Text('Move to Cart'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCheckoutSummary(
      BuildContext context, WidgetRef ref, List<CartItemModel> items) {
    final subtotal = items.fold<double>(
        0, (sum, item) => sum + (item.price * item.quantity));
    final delivery = items.isEmpty ? 0.0 : (subtotal > 500 ? 0.0 : 40.0);
    final coupon = ref.watch(couponProvider);
    final discount = coupon != null ? 50.0 : 0.0; // Flat discount
    final discountAmount = discount > subtotal ? subtotal : discount;
    final taxableAmount = subtotal - discountAmount;
    final gst = taxableAmount * 0.18;
    final total = taxableAmount + delivery + gst;

    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCouponSection(context, ref, coupon),
            const SizedBox(height: 16),
            _buildSummaryRow(context, AppLocalizations.of(context)!.subtotal,
                formatCurrency.format(subtotal)),
            const SizedBox(height: 8),
            _buildSummaryRow(
                context,
                AppLocalizations.of(context)!.deliveryCharge,
                formatCurrency.format(delivery)),
            const SizedBox(height: 8),
            if (discount > 0) ...[
              _buildSummaryRow(context, 'Coupon Discount',
                  '-${formatCurrency.format(discount)}',
                  isDiscount: true),
              const SizedBox(height: 8),
            ],
            _buildSummaryRow(context, AppLocalizations.of(context)!.gst,
                formatCurrency.format(gst)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(),
            ),
            _buildSummaryRow(context, AppLocalizations.of(context)!.grandTotal,
                formatCurrency.format(total),
                isTotal: true),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Your cart is empty. Add some products first.')));
                      } else {
                        context.push('/quote-preview');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppLocalizations.of(context)!.requestEstimate,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BuildMartButton(
                    text: AppLocalizations.of(context)!.proceedToCheckout,
                    onPressed: () {
                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Your cart is empty. Add some products first.')));
                      } else {
                        context.push('/checkout');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(
      BuildContext context, WidgetRef ref, String? appliedCoupon) {
    if (appliedCoupon != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.local_offer,
                    color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text('\'$appliedCoupon\' applied',
                    style: const TextStyle(
                        color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
            InkWell(
              onTap: () {
                ref.read(couponProvider.notifier).removeCoupon();
                _couponController.clear();
              },
              child: const Text('Remove',
                  style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            )
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _couponController,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (val) async {
              final code = val.trim().toUpperCase();
              if (code.isNotEmpty) {
                final success =
                    await ref.read(couponProvider.notifier).applyCoupon(code);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Invalid or expired coupon code.')));
                }
              }
            },
            decoration: InputDecoration(
              hintText:
                  '${AppLocalizations.of(context)!.enterPromoCode} (e.g. BUILD10)',
              hintStyle: const TextStyle(fontSize: 14),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              final code = _couponController.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                final success =
                    await ref.read(couponProvider.notifier).applyCoupon(code);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Invalid or expired coupon code.')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(AppLocalizations.of(context)!.apply,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String amount,
      {bool isTotal = false, bool isDiscount = false}) {
    final textTheme = Theme.of(context).textTheme;
    Color? textColor = isDiscount
        ? AppColors.success
        : (Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkTextLight
            : AppColors.textLight);
    if (isTotal) textColor = textTheme.bodyLarge?.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: textColor)
              : textTheme.bodyMedium?.copyWith(color: textColor),
        ),
        Text(
          amount,
          style: isTotal
              ? textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark, fontWeight: FontWeight.bold)
              : textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600, color: textColor),
        ),
      ],
    );
  }
}
