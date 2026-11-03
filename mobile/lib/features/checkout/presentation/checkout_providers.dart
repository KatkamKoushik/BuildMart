import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/data/user_repository.dart';

// Addresses
class AddressModel {
  final String id;
  final String title;
  final String addressLine;

  const AddressModel(
      {required this.id, required this.title, required this.addressLine});
}

class DeliveryAddressNotifier extends StateNotifier<AddressModel> {
  DeliveryAddressNotifier()
      : super(const AddressModel(
          id: 'initial',
          title: 'Select Location',
          addressLine: '',
        )) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final line = prefs.getString('current_delivery_address_line');
      final title = prefs.getString('current_delivery_title');
      if (line != null && line.isNotEmpty) {
        state = AddressModel(
          id: 'active_detected',
          title: title ?? 'Selected Location',
          addressLine: line,
        );
      }
    } catch (_) {}
  }

  Future<void> setAddress(
      {required String title, required String addressLine}) async {
    final newModel = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      addressLine: addressLine,
    );
    state = newModel;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_delivery_address_line', addressLine);
      await prefs.setString('current_delivery_title', title);
      final list = prefs.getStringList('local_saved_addresses') ?? [];
      if (!list.contains(addressLine)) {
        list.insert(0, addressLine);
        await prefs.setStringList('local_saved_addresses', list);
      }
    } catch (_) {}
  }
}

final deliveryAddressProvider =
    StateNotifierProvider<DeliveryAddressNotifier, AddressModel>((ref) {
  return DeliveryAddressNotifier();
});

final selectedAddressIdProvider = StateProvider<String?>((ref) => null);

final addressesProvider = Provider<List<AddressModel>>((ref) {
  final user = ref.watch(userProvider).value;
  final activeAddress = ref.watch(deliveryAddressProvider);
  final List<AddressModel> list = [];

  list.add(activeAddress);

  if (user != null && user.savedAddresses.isNotEmpty) {
    for (int i = 0; i < user.savedAddresses.length; i++) {
      final addr = user.savedAddresses[i];
      if (addr != activeAddress.addressLine) {
        list.add(AddressModel(
          id: 'user_$i',
          title: i == 0 ? 'Home' : 'Address ${i + 1}',
          addressLine: addr,
        ));
      }
    }
  }

  return list;
});

final selectedAddressProvider = Provider<AddressModel>((ref) {
  final addresses = ref.watch(addressesProvider);
  final selectedId = ref.watch(selectedAddressIdProvider);

  if (selectedId != null) {
    try {
      return addresses.firstWhere((a) => a.id == selectedId);
    } catch (_) {}
  }
  return ref.watch(deliveryAddressProvider);
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
