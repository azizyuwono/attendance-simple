import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/app_constants.dart';
import '../controllers/attendance_controller.dart';

class AttendanceScreen extends GetView<AttendanceController> {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController inputName = TextEditingController();

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
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Check In')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GoogleMap(
              myLocationEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: true,
              initialCameraPosition: const CameraPosition(
                target: AppConstants.centerLocation,
                zoom: 18,
              ),
              circles: circles,
              markers: markers,
              onMapCreated: (mapController) {
                 // We could store mapController in controller if we wanted to animate camera later
                 controller.getCurrentLocation();
              },
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Confirm Attendance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: inputName,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please input your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // Hide keyboard
                          FocusScope.of(context).unfocus();

                          final success = await controller.submitAttendance(inputName.text.trim());
                          if (success) {
                            Get.back();
                          }
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Submit Attendance'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
