import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buildmart_button.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String? orderId;
  const PaymentSuccessScreen({super.key, this.orderId});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderConfirmationText = widget.orderId != null && widget.orderId!.isNotEmpty
        ? 'Your order #${widget.orderId} has been confirmed. You will receive real-time tracking updates shortly.'
        : 'Your order has been confirmed. You will receive real-time tracking updates shortly.';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/empty_state_illustrations/payment_success_mobile_app_illus.jpeg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                orderConfirmationText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textLight,
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              BuildMartButton(
                text: 'Back to Home',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
              BuildMartButton(
                text: 'View Orders',
                isOutlined: true,
                onPressed: () => context.go('/orders'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
