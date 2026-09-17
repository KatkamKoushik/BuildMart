import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buildmart_card.dart';
import '../../../shared/widgets/buildmart_button.dart';
import '../../../shared/widgets/buildmart_text_field.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/empty_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/data/cart_repository.dart';
import '../../profile/data/user_repository.dart';
import '../../cart/data/cart_providers.dart';
import '../../auth/data/auth_provider.dart';
import 'checkout_providers.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final userId = userState.value?.id;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          icon: Icons.person_outline,
          title: 'Not logged in',
          message: 'Please sign in to proceed to checkout.',
          buttonText: 'Login',
          onAction: () async {
            await ref.read(authRepositoryProvider).logout();
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      );
    }
    
    final cartAsync = ref.watch(cartStreamProvider(userId));
    final selectedAddress = ref.watch(selectedAddressProvider);
    final selectedSlot = ref.watch(selectedDeliverySlotProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Address', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BuildMartCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            selectedAddress.title.toLowerCase() == 'home' ? Icons.home : Icons.work, 
                            color: AppColors.primary
                          ),
                          const SizedBox(width: 8),
                          Text(selectedAddress.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Semantics(
                        label: 'Edit delivery address',
                        button: true,
                        child: TextButton(
                          onPressed: () {
                            _showAddressSelectionSheet(context, ref);
                          },
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                          child: const Text('Change'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedAddress.addressLine,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textLight, height: 1.5),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Delivery Slot
            Text('Delivery Slot', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BuildMartCard(
              padding: EdgeInsets.zero,
              child: DropdownButtonFormField<String>(
                initialValue: selectedSlot,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
                items: deliverySlots.map((slot) {
                  return DropdownMenuItem(value: slot, child: Text(slot));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(selectedDeliverySlotProvider.notifier).state = val;
                  }
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Order Notes
            Text('Order Notes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BuildMartTextField(
              hintText: 'Any special instructions for delivery?',
              maxLines: 3,
              onChanged: (val) {
                ref.read(orderNotesProvider.notifier).state = val;
              },
            ),
            
            const SizedBox(height: 24),

            
            // Order Summary
            Text('Order Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            BuildMartCard(
              child: cartAsync.when(
                data: (items) {
                  final subtotal = items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
                  final delivery = items.isEmpty ? 0.0 : (subtotal > 500 ? 0.0 : 40.0);
                  
                  final coupon = ref.watch(couponProvider);
                  final discount = coupon != null ? 50.0 : 0.0;
                  final discountAmount = discount > subtotal ? subtotal : discount;
                  
                  final taxableAmount = subtotal - discountAmount;
                  final gst = taxableAmount * 0.18;
                  final total = taxableAmount + delivery + gst;

                  return Column(
                    children: [
                      _buildSummaryRow(context, 'Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      _buildSummaryRow(context, 'Delivery Charges', '₹${delivery.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      _buildSummaryRow(context, 'GST (18%)', '₹${gst.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      if (discountAmount > 0)
                        _buildSummaryRow(context, 'Coupon Discount', '- ₹${discountAmount.toStringAsFixed(2)}', color: AppColors.success)
                      else
                        _buildSummaryRow(context, 'Coupon Discount', '- ₹0.00', color: AppColors.success),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(),
                      ),
                      _buildSummaryRow(context, 'Grand Total', '₹${total.toStringAsFixed(2)}', isTotal: true),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: ShimmerLoader(width: 200, height: 100),
                  ),
                ),
                error: (e, st) => const Text('Error loading summary'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BuildMartButton(
            text: 'Continue to Payment',
            onPressed: () {
              final items = cartAsync.valueOrNull;
              if (items != null) {
                final subtotal = items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
                final delivery = items.isEmpty ? 0.0 : (subtotal > 500 ? 0.0 : 40.0);
                
                final coupon = ref.read(couponProvider);
                final discount = coupon != null ? 50.0 : 0.0;
                final discountAmount = discount > subtotal ? subtotal : discount;
                
                final taxableAmount = subtotal - discountAmount;
                final gst = taxableAmount * 0.18;
                final total = taxableAmount + delivery + gst;
                context.push('/payment', extra: total);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is still loading...')));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String amount, {bool isTotal = false, Color? color}) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final labelColor = isDark ? AppColors.darkTextLight : AppColors.textLight;
    final valueColor = color ?? (isDark ? AppColors.darkText : AppColors.text);
    final totalValueColor = color ?? (isDark ? AppColors.primary : AppColors.primaryDark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal 
              ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : textTheme.bodyMedium?.copyWith(color: labelColor),
        ),
        Text(
          amount,
          style: isTotal
              ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: totalValueColor)
              : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }

  void _showAddressSelectionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final addresses = ref.watch(addressesProvider);
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Address', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...addresses.map((addr) {
                    final isSelected = ref.watch(selectedAddressProvider).id == addr.id;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(addr.title.toLowerCase() == 'home' ? Icons.home : Icons.work, color: isSelected ? AppColors.primary : AppColors.textLight),
                      title: Text(addr.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(addr.addressLine, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                      onTap: () {
                        ref.read(selectedAddressIdProvider.notifier).state = addr.id;
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  BuildMartButton(
                    text: 'Add New Address',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add address flow coming soon!')));
                    },
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }
}
