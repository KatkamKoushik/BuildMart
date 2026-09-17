import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../application/quote_generator_service.dart';
import '../../cart/data/cart_providers.dart';
import '../../cart/data/cart_repository.dart';
import '../../profile/data/user_repository.dart';

class QuotePreviewScreen extends ConsumerWidget {
  const QuotePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final userId = userState.value?.id;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quote Preview')),
        body: const Center(child: Text('Please log in to generate quotes')),
      );
    }

    final cartAsync = ref.watch(cartStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: cartAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final subtotal = items.fold<double>(0, (sum, item) => sum + (item.price * item.quantity));
          final coupon = ref.watch(couponProvider);
          final discount = coupon != null ? 50.0 : 0.0;
          final discountAmount = discount > subtotal ? subtotal : discount;
          final taxableAmount = subtotal - discountAmount;
          final gst = taxableAmount * 0.18;
          final total = taxableAmount + gst; // Omitting delivery for quote

          return PdfPreview(
            build: (format) => QuoteGeneratorService.generateQuote(
              user: userState.value,
              items: items,
              subtotal: subtotal,
              gst: gst,
              total: total,
              discount: discountAmount,
            ),
            canChangeOrientation: false,
            canChangePageFormat: false,
            allowPrinting: true,
            allowSharing: true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
