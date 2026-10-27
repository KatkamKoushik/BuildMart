import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/data/user_repository.dart';

// Addresses
class AddressModel {
  final String id;
  final String title;
  final String addressLine;

  const AddressModel(
      {required this.id, required this.title, required this.addressLine});
}

final addressesProvider = Provider<List<AddressModel>>((ref) {
  final user = ref.watch(userProvider).value;
  if (user == null || user.savedAddresses.isEmpty) {
    return [
      const AddressModel(
          id: '1',
          title: 'Home',
          addressLine: 'Please add an address in your profile.'),
    ];
  }

  return user.savedAddresses.asMap().entries.map((entry) {
    return AddressModel(
      id: entry.key.toString(),
      title: entry.key == 0 ? 'Home' : 'Address ${entry.key + 1}',
      addressLine: entry.value,
    );
  }).toList();
});

final selectedAddressIdProvider = StateProvider<String?>((ref) => null);

final selectedAddressProvider = Provider<AddressModel>((ref) {
  final addresses = ref.watch(addressesProvider);
  final selectedId = ref.watch(selectedAddressIdProvider);

  if (selectedId != null) {
    try {
      return addresses.firstWhere((a) => a.id == selectedId);
    } catch (_) {}
  }
  return addresses.first;
});

// Delivery Slots
const deliverySlots = [
  'Today, 10 AM - 1 PM',
  'Today, 2 PM - 5 PM',
  'Tomorrow, 10 AM - 1 PM',
  'Tomorrow, 2 PM - 5 PM',
];

final selectedDeliverySlotProvider =
    StateProvider<String>((ref) => deliverySlots.first);

// Order Notes
final orderNotesProvider = StateProvider<String>((ref) => '');
