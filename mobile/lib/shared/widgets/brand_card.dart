import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/brand_assets.dart';
import 'network_image_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BrandCard extends StatelessWidget {
  final String name;
  final String logoUrl;
  final VoidCallback onTap;

  const BrandCard({
    super.key,
    required this.name,
    required this.logoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.background;
    final labelBg = isDark ? AppColors.darkSecondaryBackground : AppColors.secondaryBackground;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.3);
    final textColor = isDark ? AppColors.darkText : AppColors.text;

    final resolvedLogo = BrandAssets.resolveLogoUrl(name, logoUrl, name);
    final offlineAsset = BrandAssets.getOfflineLogo(name, name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: NetworkImageWidget(
                  imageUrl: resolvedLogo,
                  fallbackAsset: offlineAsset,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: labelBg,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(duration: 400.ms, curve: Curves.easeOut);
  }
}
