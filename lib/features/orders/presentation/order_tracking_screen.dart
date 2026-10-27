import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buildmart_card.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final LatLng _agentLocation =
      const LatLng(17.4359, 78.4042); // Example Jubilee Hills
  final LatLng _destinationLocation = const LatLng(17.4330, 78.4010);

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
          TextButton(
            onPressed: () {},
            child:
                const Text('Help', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _agentLocation,
                zoom: 15.0,
              ),
              markers: {
                Marker(
                    markerId: const MarkerId('agent'),
                    position: _agentLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueYellow)),
                Marker(
                    markerId: const MarkerId('destination'),
                    position: _destinationLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed)),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: AppColors.primary,
                  width: 4,
                  points: [_agentLocation, _destinationLocation],
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),

          // Draggable Sheet overlay
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5))
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 24),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Header
                            Text('Arriving in 15 mins',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Your order is out for delivery',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textLight)),
                            const SizedBox(height: 24),

                            // Delivery Agent Details
                            BuildMartCard(
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(
                                        'https://via.placeholder.com/150'),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Ramesh Kumar',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Row(
                                          children: [
                                            const Text('TS09 AB 1234',
                                                style: TextStyle(
                                                    color: AppColors.textLight,
                                                    fontSize: 12)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.star,
                                                      size: 12,
                                                      color: AppColors.primary),
                                                  SizedBox(width: 2),
                                                  Text('4.9',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .primary)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Semantics(
                                    label: 'Call delivery agent',
                                    button: true,
                                    child: CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      child: IconButton(
                                        icon: const Icon(Icons.call,
                                            color: AppColors.accent),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // OTP Verification
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Delivery OTP',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                  color: AppColors.textLight)),
                                      const SizedBox(height: 4),
                                      Text('8 4 9 2',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 4)),
                                    ],
                                  ),
                                  ElevatedButton(
                                    // Normally disabled until agent marks as arrived, used here to advance flow
                                    onPressed: () =>
                                        context.push('/delivery-success'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.accent),
                                    child: const Text('Verify (Demo)'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Order Timeline
                            Text('Order Timeline',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildTimelineStep(context, 'Order Confirmed',
                                '10:30 AM, 12 Oct', true),
                            _buildTimelineStep(context, 'Order Packed',
                                '11:15 AM, 12 Oct', true),
                            _buildTimelineStep(context, 'Out for Delivery',
                                '12:00 PM, 12 Oct', true,
                                isActive: true),
                            _buildTimelineStep(
                                context, 'Delivered', 'Pending', false,
                                isLast: true),
                            const SizedBox(height: 40),
                          ],
                        ),
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

  Widget _buildTimelineStep(
      BuildContext context, String title, String subtitle, bool isCompleted,
      {bool isLast = false, bool isActive = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success
                    : AppColors.secondaryBackground,
                border:
                    isCompleted ? null : Border.all(color: AppColors.border),
              ),
              child: isCompleted
                  ? const Icon(Icons.check,
                      size: 16, color: AppColors.background)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.success : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted || isActive
                        ? AppColors.text
                        : AppColors.textLight,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ],
    );
  }
}
