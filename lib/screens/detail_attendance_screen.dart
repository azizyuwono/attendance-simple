import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/attendance.dart';

class DetailAttendanceScreen extends StatelessWidget {
  const DetailAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Attendance detail = Get.arguments;

    final Set<Circle> circles = {
      Circle(
        strokeWidth: 2,
        fillColor: Colors.greenAccent.withValues(alpha: 0.3),
        strokeColor: Colors.greenAccent,
        circleId: const CircleId('center'),
        center: AppConstants.centerLocation,
        radius: AppConstants.maxAttendanceDistanceInMeters,
      )
    };

    final Set<Marker> markers = {
      const Marker(
        markerId: MarkerId('center'),
        position: AppConstants.centerLocation,
        infoWindow: InfoWindow(
          title: 'Attendance point',
          snippet: 'Main Office',
        ),
      ),
      Marker(
        markerId: const MarkerId('detail'),
        position: LatLng(detail.latitude, detail.longitude),
        infoWindow: InfoWindow(
          title: 'Attendance location',
          snippet: DateFormat('dd MMM y H:mm').format(detail.createdAt),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    double calculateDistance() => Geolocator.distanceBetween(
        AppConstants.centerLatitude,
        AppConstants.centerLongitude,
        detail.latitude,
        detail.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Details')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: const CameraPosition(
                target: AppConstants.centerLocation,
                zoom: 18,
              ),
              circles: circles,
              markers: markers,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(
                            detail.name.isNotEmpty ? detail.name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              DateFormat('EEEE, dd MMM yyyy, HH:mm').format(detail.createdAt),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(context, 'Distance', '${calculateDistance().toStringAsFixed(1)} meters from Center'),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, 'Coordinates', '${detail.latitude.toStringAsFixed(6)}, ${detail.longitude.toStringAsFixed(6)}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
