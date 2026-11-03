import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shimmer_loader.dart';
import '../../core/constants/app_colors.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final String? fallbackAsset;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAsset = imageUrl.startsWith('assets/');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackBg =
        isDark ? AppColors.darkCard : AppColors.secondaryBackground;

    Widget defaultFallback() {
      if (fallbackAsset != null && fallbackAsset!.isNotEmpty) {
        return Image.asset(
          fallbackAsset!,
          width: width,
          height: height,
          fit: fit,
        );
      }
      return Container(
        width: width,
        height: height,
        color: fallbackBg,
        child: Center(
          child: Image.asset(
            'assets/images/empty_state_illustrations/empty_delivery_box_illustration.jpeg',
            width: width != null ? width! * 0.5 : 40,
            height: height != null ? height! * 0.5 : 40,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: isAsset
          ? Image.asset(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) =>
                  errorWidget ?? defaultFallback(),
            )
          : (imageUrl.isEmpty
              ? (errorWidget ?? defaultFallback())
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: width,
                  height: height,
                  fit: fit,
                  placeholder: (context, url) => ShimmerLoader(
                    width: width ?? double.infinity,
                    height: height ?? double.infinity,
                    borderRadius: BorderRadius.zero,
                  ),
                  errorWidget: (context, url, error) =>
                      errorWidget ?? defaultFallback(),
                )),
    );
  }
}
