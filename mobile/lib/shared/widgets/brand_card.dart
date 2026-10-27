import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.04),
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
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
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
