import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            context,
            icon: Icons.local_shipping,
            color: AppColors.primary,
            title: 'Order Out for Delivery',
            description:
                'Your order #BM8472 is out for delivery and will reach you in 45 mins.',
            time: 'Just now',
            isUnread: true,
          ),
          _buildNotificationItem(
            context,
            icon: Icons.local_offer,
            color: AppColors.success,
            title: 'Special Offer on UltraTech',
            description:
                'Get 10% off on bulk orders of UltraTech cement. Valid till midnight.',
            time: '2 hours ago',
            isUnread: true,
          ),
          _buildNotificationItem(
            context,
            icon: Icons.check_circle,
            color: AppColors.textLight,
            title: 'Payment Successful',
            description:
                'We have received your payment of ₹14,500 for order #BM8471.',
            time: 'Yesterday',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
