import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dummy_images.dart';
import '../../../shared/widgets/buildmart_button.dart';
import '../../../shared/widgets/buildmart_text_field.dart';
import '../../../shared/widgets/network_image_widget.dart';

class DeliverySuccessScreen extends StatefulWidget {
  const DeliverySuccessScreen({super.key});

  @override
  State<DeliverySuccessScreen> createState() => _DeliverySuccessScreenState();
}

class _DeliverySuccessScreenState extends State<DeliverySuccessScreen> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const NetworkImageWidget(
                imageUrl: DummyImages.illustrationSuccess,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'Delivered Successfully!',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order was delivered securely.',
                style: TextStyle(color: AppColors.textLight, fontSize: 16),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 24),

              // Rating Section
              const Text('How was your experience?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: 40,
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),

              if (_rating > 0) ...[
                const BuildMartTextField(
                  hintText: 'Write a review (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review Submitted!')));
                    },
                    child: const Text('Submit Review',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Action Buttons
              BuildMartButton(
                text: 'Repeat Order',
                icon: Icons.replay,
                onPressed: () =>
                    context.go('/cart'), // Navigates to cart as mock for repeat
              ),
              const SizedBox(height: 16),
              BuildMartButton(
                text: 'Continue Shopping',
                isOutlined: true,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
