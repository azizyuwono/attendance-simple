import 'dart:developer';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_constants.dart';
import '../models/attendance.dart';
import '../repository/attendance_repository.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class AttendanceController extends GetxController {
  final LocationService _locationService;
  final AttendanceRepository _attendanceRepository;
  final NotificationService _notificationService;

  AttendanceController(this._locationService, this._attendanceRepository, this._notificationService);

  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxList<Attendance> listAttendances = <Attendance>[].obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  Position? currentPosition;

  final Rx<Position?> currentPositionRx = Rx<Position?>(null);

  @override
  void onInit() {
    super.onInit();
    // Initial fetch
    getListAttendances();
  }

  Future<void> getCurrentLocation() async {
    try {
      currentPosition = await _locationService.getCurrentPosition();
      currentPositionRx.value = currentPosition;
    } catch (e) {
      errorMessage.value = e.toString();
      _notificationService.showSnackbar('Location Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> getListAttendances() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _attendanceRepository.readAllAttendances();
      listAttendances.assignAll(response);
      isError.value = false;
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      log('error read list: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitAttendance(String name) async {
    // Refresh location before submitting to ensure accuracy
    try {
      await getCurrentLocation();
    } catch (e) {
      _notificationService.showSnackbar('Error', 'Could not get current location: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (currentPosition == null) {
      _notificationService.showSnackbar('Error', 'Location not detected. Please try again.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    try {
      final distance = _locationService.calculateDistance(
        AppConstants.centerLatitude,
        AppConstants.centerLongitude,
        currentPosition!.latitude,
        currentPosition!.longitude,
      );

      log('distance from center: $distance');

      if (distance > AppConstants.maxAttendanceDistanceInMeters) {
         _notificationService.showSnackbar(
           'Out of Range',
           'You are ${distance.toStringAsFixed(1)}m away. Max allowed is ${AppConstants.maxAttendanceDistanceInMeters}m.',
           snackPosition: SnackPosition.BOTTOM
         );
        return false;
      }

      await _attendanceRepository.create(
        Attendance(
          name: name,
          latitude: currentPosition!.latitude,
          longitude: currentPosition!.longitude,
          createdAt: DateTime.now(),
        ),
      );

      // Refresh list
      await getListAttendances();

      _notificationService.showSnackbar('Success', 'Attendance submitted successfully', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      log('error submit: ${e.toString()}');
      _notificationService.showSnackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
