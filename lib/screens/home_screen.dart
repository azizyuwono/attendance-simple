import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../controllers/attendance_controller.dart';
import '../routes/route_names.dart';

class HomeScreen extends GetView<AttendanceController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value ?? 'Error fetching data',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => controller.getListAttendances(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                )
              ],
            ),
          );
        }

        if (controller.listAttendances.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No attendances recorded yet.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => controller.getListAttendances(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                )
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.listAttendances.length,
          itemBuilder: (context, index) {
            final attendance = controller.listAttendances[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: ListTile(
                onTap: () => Get.toNamed(RouteNames.detailAttendanceScreen,
                    arguments: attendance),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    attendance.name.isNotEmpty ? attendance.name[0].toUpperCase() : '?',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
                title: Text(attendance.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    DateFormat('EEE, dd MMM yyyy, HH:mm').format(attendance.createdAt)),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(RouteNames.attendanceScreen),
        icon: const Icon(Icons.add),
        label: const Text('Check In'),
      ),
    );
  }
}
