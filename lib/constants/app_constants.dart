import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConstants {
  // App Config
  static const String appName = 'Attendance App';

  // Location
  static const double centerLatitude = -8.1735199;
  static const double centerLongitude = 113.6976335;
  static const LatLng centerLocation = LatLng(centerLatitude, centerLongitude);
  static const double maxAttendanceDistanceInMeters = 50.0;

  // Database
  static const String dbName = 'attendance_app.db';
  static const int dbVersion = 2;
  static const String tableAttendances = 'tb_attendance';
}
