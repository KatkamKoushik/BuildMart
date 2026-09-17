import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buildmart_button.dart';
import '../../../shared/widgets/payment_method_card.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  const PaymentScreen({super.key, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0;
  late Razorpay _razorpay;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _methods = [
    {'title': 'Razorpay (UPI, Cards, NetBanking)', 'icon': Icons.account_balance_wallet},
    {'title': 'Cash on Delivery', 'icon': Icons.local_shipping},
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _isProcessing = false);
    context.go('/payment-success');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}', style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  void _processPayment() {
    if (_selectedPaymentMethod == 1) {
      // COD Selected
      context.go('/payment-success');
      return;
    }

    // Razorpay Flow
    setState(() => _isProcessing = true);
    
    // In a real app, you would fetch the order_id from your backend here.
    // We are proceeding with a client-side mock for the prototype.
    var options = {
      'key': dotenv.env['RAZORPAY_KEY_ID'] ?? 'rzp_test_TM6Z7BqbHQaK7R',

      'amount': (widget.amount * 100).toInt(), // Amount in paise
      'name': 'BuildMart',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9876543210',
        'email': 'customer@buildmart.com'
      },
      'theme': {
        'color': '#FFC107' // App primary color
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount to Pay', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textLight)),
            const SizedBox(height: 4),
            Text('₹${widget.amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 32),
            Text('Select Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(_methods.length, (index) {
              return PaymentMethodCard(
                title: _methods[index]['title'],
                icon: _methods[index]['icon'],
                isSelected: _selectedPaymentMethod == index,
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = index;
                  });
                },
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BuildMartButton(
            text: _isProcessing ? 'Processing...' : 'Pay Securely',
            isLoading: _isProcessing,
            onPressed: _processPayment,
          ),
        ),
      ),
    );
  }
}
