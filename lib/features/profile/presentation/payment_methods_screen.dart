import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/payment_method_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/payment_method_card.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedMethod = 'Card ending in 1234';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.paymentMethods),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            AppLocalizations.of(context)!.savedCards,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PaymentMethodCard(
            title: AppLocalizations.of(context)!.cardEnding1234,
            icon: Icons.credit_card,
            isSelected: _selectedMethod == 'Card ending in 1234',
            onTap: () {
              setState(() => _selectedMethod = 'Card ending in 1234');
            },
          ),
          PaymentMethodCard(
            title: AppLocalizations.of(context)!.cardEnding9876,
            icon: Icons.credit_card,
            isSelected: _selectedMethod == 'Card ending in 9876',
            onTap: () {
              setState(() => _selectedMethod = 'Card ending in 9876');
            },
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.upiWallets,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PaymentMethodCard(
            title: 'PhonePe UPI',
            icon: Icons.account_balance_wallet,
            isSelected: _selectedMethod == 'PhonePe UPI',
            onTap: () {
              setState(() => _selectedMethod = 'PhonePe UPI');
            },
          ),
          PaymentMethodCard(
            title: 'Google Pay',
            icon: Icons.g_mobiledata,
            isSelected: _selectedMethod == 'Google Pay',
            onTap: () {
              setState(() => _selectedMethod = 'Google Pay');
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
            icon: Icons.money,
            isSelected: _selectedMethod == 'Cash on Delivery',
            onTap: () {
              setState(() => _selectedMethod = 'Cash on Delivery');
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add new payment method feature coming soon!')),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addNewPaymentMethod),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
