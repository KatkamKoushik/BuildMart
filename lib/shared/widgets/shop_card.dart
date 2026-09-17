import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'network_image_widget.dart';
import '../../features/shops/data/shop_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
class ShopCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;

  const ShopCard({
    super.key,
    required this.shop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Shop: ${shop.name}, Rating: ${shop.rating}, Distance: ${shop.distance} kilometers away',
      button: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image & Logo Inset
                Stack(
                  children: [
                    NetworkImageWidget(
                      imageUrl: shop.coverImageUrl,
                      height: 120,
                      width: double.infinity,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: shop.isOpen ? AppColors.success : AppColors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          shop.isOpen ? 'OPEN' : 'CLOSED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -24,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: NetworkImageWidget(
                          imageUrl: shop.logoUrl,
                          width: 48,
                          height: 48,
                          borderRadius: const BorderRadius.all(Radius.circular(24)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32), // space for logo inset
                // Shop Details
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              shop.name,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text('${shop.rating}', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(shop.address, style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textLight)),
                          const SizedBox(width: 16),
                          const Icon(Icons.directions_walk, size: 14, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text('${shop.distance} away', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textLight)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
