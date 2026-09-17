import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoader(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader(width: 100, height: 14),
                SizedBox(height: 8),
                ShimmerLoader(width: 120, height: 16),
                SizedBox(height: 12),
                ShimmerLoader(width: 80, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemShimmer extends StatelessWidget {
  const CartItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            ShimmerLoader(width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(8))),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoader(width: 150, height: 16),
                  SizedBox(height: 8),
                  ShimmerLoader(width: 80, height: 14),
                ],
              ),
            ),
            SizedBox(width: 12),
            ShimmerLoader(width: 40, height: 20),
          ],
        ),
      ),
    );
  }
}

class ShopCardShimmer extends StatelessWidget {
  const ShopCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoader(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader(width: 120, height: 16),
                SizedBox(height: 8),
                ShimmerLoader(width: 80, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoader(width: double.infinity, height: 350, borderRadius: BorderRadius.zero),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader(width: 100, height: 14),
                SizedBox(height: 8),
                ShimmerLoader(width: 250, height: 24),
                SizedBox(height: 16),
                ShimmerLoader(width: 150, height: 20),
                SizedBox(height: 24),
                ShimmerLoader(width: double.infinity, height: 100),
                SizedBox(height: 24),
                ShimmerLoader(width: 120, height: 20),
                SizedBox(height: 8),
                ShimmerLoader(width: double.infinity, height: 16),
                SizedBox(height: 4),
                ShimmerLoader(width: double.infinity, height: 16),
                SizedBox(height: 4),
                ShimmerLoader(width: 200, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCardShimmer extends StatelessWidget {
  const OrderCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerLoader(width: 100, height: 16),
                ShimmerLoader(width: 60, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
              ],
            ),
            SizedBox(height: 12),
            ShimmerLoader(width: 150, height: 14),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerLoader(width: 80, height: 16),
                ShimmerLoader(width: 100, height: 36, borderRadius: BorderRadius.all(Radius.circular(8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
