import 'package:flutter/material.dart';
import '../../../shared/widgets/payment_method_card.dart';
import '../../../l10n/app_localizations.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedMethod = 'Razorpay Secure';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.paymentMethods),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Online Payments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PaymentMethodCard(
            title: 'Razorpay Secure (Credit / Debit Card, NetBanking)',
            icon: Icons.credit_card,
            isSelected: _selectedMethod == 'Razorpay Secure',
            onTap: () {
              setState(() => _selectedMethod = 'Razorpay Secure');
            },
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.upiWallets,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PaymentMethodCard(
            title: 'Instant UPI (Google Pay, PhonePe, Paytm)',
            icon: Icons.account_balance_wallet,
            isSelected: _selectedMethod == 'Instant UPI',
            onTap: () {
              setState(() => _selectedMethod = 'Instant UPI');
            },
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.cash,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PaymentMethodCard(
            title: AppLocalizations.of(context)!.cashOnDelivery,
            icon: Icons.local_shipping,
            isSelected: _selectedMethod == 'Cash on Delivery',
            onTap: () {
              setState(() => _selectedMethod = 'Cash on Delivery');
            },
          ),
        ],
      ),
    );
  }
}
