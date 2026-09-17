import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buildmart_button.dart';
import '../../../shared/widgets/buildmart_text_field.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../checkout/presentation/checkout_providers.dart';
import '../../profile/data/user_repository.dart';
import 'city_search_modal.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final TextEditingController _pincodeController = TextEditingController();
  bool _isDetecting = false;

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isDetecting = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      } 

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final detectedLoc = '${place.locality ?? ''}, ${place.administrativeArea ?? ''} ${place.postalCode ?? ''}';
        
        final user = ref.read(userProvider).value;
        if (user != null) {
          await ref.read(userRepositoryProvider).addSavedAddress(user.id, detectedLoc);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detected: $detectedLoc'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDetecting = false);
      }
    }
  }

  void _submitPincode(String pincode) async {
    if (pincode.isEmpty || pincode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid pincode'), backgroundColor: AppColors.error),
      );
      return;
    }
    
    final user = ref.read(userProvider).value;
    if (user != null) {
      await ref.read(userRepositoryProvider).addSavedAddress(user.id, 'Pincode: $pincode');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pincode $pincode applied!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detect Location Button
            BuildMartButton(
              text: _isDetecting ? 'Detecting...' : 'Detect My Location',
              onPressed: _isDetecting ? null : _detectLocation,
              // Assuming you can pass an icon to a custom button later, we use standard elevated button here if needed
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('OR', style: TextStyle(color: AppColors.textLight)),
                ),
                Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Pincode',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: BuildMartTextField(
                    controller: _pincodeController,
                    hintText: 'e.g. 500081',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.pin_drop_outlined),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: _submitPincode,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _submitPincode(_pincodeController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Select City Manually',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Search for your city'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final selectedCity = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        top: MediaQuery.of(context).padding.top + 64,
                      ),
                      child: const CitySearchModal(),
                    ),
                  );
                  
                  if (selectedCity != null && mounted) {
                    final user = ref.read(userProvider).value;
                    if (user != null) {
                      await ref.read(userRepositoryProvider).addSavedAddress(user.id, selectedCity);
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('City selected: $selectedCity'), backgroundColor: AppColors.success),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Saved Locations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ref.watch(addressesProvider).map((addr) => _buildSavedLocation(
                  context,
                  ref,
                  addr.title,
                  addr.addressLine.replaceAll('\n', ', '),
                  addr.title.toLowerCase().contains('home') ? Icons.home : Icons.work,
                  addr,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedLocation(BuildContext context, WidgetRef ref, String title, String address, IconData icon, AddressModel addr) {
    final selectedAddress = ref.watch(selectedAddressProvider);
    final isSelected = selectedAddress.id == addr.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(address, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : const Icon(Icons.more_vert),
        onTap: () {
          ref.read(selectedAddressIdProvider.notifier).state = addr.id;
        },
      ),
    );
  }
}
