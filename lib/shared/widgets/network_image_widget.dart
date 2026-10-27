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

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAsset = imageUrl.startsWith('assets/');

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: isAsset
          ? Image.asset(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) =>
                  errorWidget ??
                  Container(
                    width: width,
                    height: height,
                    color: AppColors.secondaryBackground,
                    child: Center(
                      child: Image.asset(
                        'assets/images/empty_state_illustrations/empty_delivery_box_illustration.jpeg',
                        width: width != null ? width! * 0.5 : 50,
                        height: height != null ? height! * 0.5 : 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
            )
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
                  errorWidget ??
                  Container(
                    width: width,
                    height: height,
                    color: AppColors.secondaryBackground,
                    child: Center(
                      child: Image.asset(
                        'assets/images/empty_state_illustrations/empty_delivery_box_illustration.jpeg',
                        width: width != null ? width! * 0.5 : 50,
                        height: height != null ? height! * 0.5 : 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
            ),
    );
  }
}
