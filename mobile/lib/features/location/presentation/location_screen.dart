import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buildmart_button.dart';
import '../../../shared/widgets/buildmart_text_field.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        final parts = [
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
        ]
            .where(
                (p) => p != null && p.trim().isNotEmpty && p != 'Unnamed Road')
            .toSet()
            .toList();
        if (parts.isEmpty && place.name != null && place.name!.isNotEmpty) {
          parts.add(place.name!);
        }
        final detectedLoc =
            parts.isNotEmpty ? parts.join(', ') : 'Current Location';
        final title = (place.locality?.isNotEmpty == true)
            ? place.locality!
            : (place.subLocality?.isNotEmpty == true
                ? place.subLocality!
                : 'Detected Location');

        await ref
            .read(deliveryAddressProvider.notifier)
            .setAddress(title: title, addressLine: detectedLoc);

        final user = ref.read(userProvider).value;
        if (user != null) {
          await ref
              .read(userRepositoryProvider)
              .addSavedAddress(user.id, detectedLoc);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Detected: $detectedLoc'),
                backgroundColor: AppColors.success),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
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
        const SnackBar(
            content: Text('Please enter a valid pincode'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    final addrLine = 'Pincode: $pincode, Delivery Area';
    await ref
        .read(deliveryAddressProvider.notifier)
        .setAddress(title: 'Pincode $pincode', addressLine: addrLine);

    final user = ref.read(userProvider).value;
    if (user != null) {
      await ref.read(userRepositoryProvider).addSavedAddress(user.id, addrLine);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Pincode $pincode applied!'),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: Divider(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child:
                      Text('OR', style: TextStyle(color: AppColors.textLight)),
                ),
                Expanded(
                    child: Divider(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Pincode',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
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
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Select City Manually',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSecondaryBackground
                    : AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.location_city, color: AppColors.primary),
                title: Text(
                  'Search for your city',
                  style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.darkTextLight : AppColors.textLight,
                ),
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
                    final addrLine = '$selectedCity, India';
                    await ref
                        .read(deliveryAddressProvider.notifier)
                        .setAddress(title: selectedCity, addressLine: addrLine);

                    final user = ref.read(userProvider).value;
                    if (user != null) {
                      await ref
                          .read(userRepositoryProvider)
                          .addSavedAddress(user.id, addrLine);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('City selected: $selectedCity'),
                            backgroundColor: AppColors.success),
                      );
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Saved Locations',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ref.watch(addressesProvider).map((addr) => _buildSavedLocation(
                  context,
                  ref,
                  addr.title,
                  addr.addressLine.replaceAll('\n', ', '),
                  addr.title.toLowerCase().contains('home')
                      ? Icons.home
                      : Icons.work,
                  addr,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedLocation(BuildContext context, WidgetRef ref, String title,
      String address, IconData icon, AddressModel addr) {
    final selectedAddress = ref.watch(selectedAddressProvider);
    final isSelected = selectedAddress.id == addr.id ||
        selectedAddress.addressLine == addr.addressLine;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.12)
            : (isDark
                ? AppColors.darkSecondaryBackground
                : AppColors.background),
        border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        subtitle: Text(
          address,
          style: TextStyle(
            color: isDark ? AppColors.darkTextLight : AppColors.textLight,
            fontSize: 12,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : Icon(
                Icons.more_vert,
                color: isDark ? AppColors.darkTextLight : AppColors.textLight,
              ),
        onTap: () async {
          await ref.read(deliveryAddressProvider.notifier).setAddress(
                title: addr.title,
                addressLine: addr.addressLine,
              );
          ref.read(selectedAddressIdProvider.notifier).state = addr.id;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected: ${addr.title}'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
