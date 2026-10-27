import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/shop_card.dart';
import '../../../core/constants/app_colors.dart';
import '../data/shop_repository.dart';
import 'package:go_router/go_router.dart';

class NearbyShopsScreen extends ConsumerStatefulWidget {
  const NearbyShopsScreen({super.key});

  @override
  ConsumerState<NearbyShopsScreen> createState() => _NearbyShopsScreenState();
}

class _NearbyShopsScreenState extends ConsumerState<NearbyShopsScreen> {
  static const LatLng _initialPosition = LatLng(17.4326, 78.4071); // Hyderabad

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(nearbyShopsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Shops'),
        backgroundColor:
            Colors.transparent, // Making appbar transparent over map
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.accent),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Google Map Background
          const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Draggable Bottom Sheet for Shops
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Text('Shops near you',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: shopsAsync.when(
                        data: (shops) {
                          if (shops.isEmpty) {
                            return const Center(
                                child: Text('No shops found nearby.'));
                          }
                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: shops.length,
                            itemBuilder: (context, index) {
                              final shop = shops[index];
                              return ShopCard(
                                shop: shop,
                                onTap: () => context.push('/shop/${shop.id}'),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) =>
                            Center(child: Text('Error loading shops: $error')),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
