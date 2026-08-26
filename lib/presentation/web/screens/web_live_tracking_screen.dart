import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/journey_model.dart';
import '../../../data/models/location_point.dart';
import '../../journey/providers/journey_provider.dart';

class WebLiveTrackingScreen extends ConsumerWidget {
  final String journeyId;

  const WebLiveTrackingScreen({
    super.key,
    required this.journeyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(journeyRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: AppColors.accent, size: 22),
            SizedBox(width: 8),
            Text('SafeCircle Web Live Tracker'),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<JourneyModel?>(
        stream: repository.watchJourneyById(journeyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final journey = snapshot.data;

          if (journey == null) {
            return _buildExpiredCard('Journey Link Expired or Not Found');
          }

          final isExpired = DateTime.now().isAfter(journey.expiresAt);
          if (isExpired || !journey.isActive) {
            return _buildExpiredCard(
              !journey.isActive
                  ? 'Journey Completed - User Arrived Safely'
                  : 'Tracking Link Expired',
            );
          }

          return StreamBuilder<List<LocationPoint>>(
            stream: repository.watchJourneyLocations(journeyId),
            builder: (context, locSnapshot) {
              final locations = locSnapshot.data ?? [];
              final latestLoc = locations.isNotEmpty
                  ? locations.first
                  : (journey.lastKnownLocation ??
                      LocationPoint(
                        latitude: 37.7749,
                        longitude: -122.4194,
                        timestamp: DateTime.now(),
                      ));

              final centerLatLng = LatLng(latestLoc.latitude, latestLoc.longitude);

              return Column(
                children: [
                  // Status Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    color: AppColors.surface,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                journey.destinationName ?? 'Active Journey Tracking',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Last updated: ${latestLoc.timestamp.hour}:${latestLoc.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // FlutterMap Tile & Marker Layer
                  Expanded(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: centerLatLng,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.safecircle.safecircle',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: centerLatLng,
                              width: 44,
                              height: 44,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black38, blurRadius: 6),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildExpiredCard(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.textMuted, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'For privacy and safety reasons, disposable tracking links stop providing location updates once the journey ends or expires.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
