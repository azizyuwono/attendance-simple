import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:attendanceapp/services/location_service.dart';
import 'package:attendanceapp/repository/attendance_repository.dart';
import 'package:attendanceapp/services/database_service.dart';
import 'package:attendanceapp/services/notification_service.dart';

@GenerateMocks([
  LocationService,
  AttendanceRepository,
  DatabaseService,
  NotificationService,
  Database,
])
void main() {}
