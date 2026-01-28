import 'package:attendanceapp/controllers/attendance_controller.dart';
import 'package:attendanceapp/models/attendance.dart';
import 'package:attendanceapp/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';

import '../../test_helper.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AttendanceController controller;
  late MockLocationService mockLocationService;
  late MockAttendanceRepository mockAttendanceRepository;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockLocationService = MockLocationService();
    mockAttendanceRepository = MockAttendanceRepository();
    mockNotificationService = MockNotificationService();
    controller = AttendanceController(mockLocationService, mockAttendanceRepository, mockNotificationService);
  });

  final mockPosition = Position(
    longitude: AppConstants.centerLongitude,
    latitude: AppConstants.centerLatitude,
    timestamp: DateTime.now(),
    accuracy: 1.0,
    altitude: 1.0,
    heading: 1.0,
    speed: 1.0,
    speedAccuracy: 1.0,
    altitudeAccuracy: 1.0,
    headingAccuracy: 1.0,
    isMocked: true,
  );

  final mockPositionFar = Position(
    longitude: AppConstants.centerLongitude + 0.1, // Far away
    latitude: AppConstants.centerLatitude + 0.1,
    timestamp: DateTime.now(),
    accuracy: 1.0,
    altitude: 1.0,
    heading: 1.0,
    speed: 1.0,
    speedAccuracy: 1.0,
    altitudeAccuracy: 1.0,
    headingAccuracy: 1.0,
    isMocked: true,
  );

  group('AttendanceController', () {
    test('getCurrentLocation updates currentPosition on success', () async {
      when(mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => mockPosition);

      await controller.getCurrentLocation();

      expect(controller.currentPosition, mockPosition);
      expect(controller.currentPositionRx.value, mockPosition);
    });

    test('submitAttendance success when in range', () async {
      when(mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => mockPosition);

      when(mockLocationService.calculateDistance(any, any, any, any))
          .thenReturn(10.0); // 10 meters

      when(mockAttendanceRepository.create(any))
          .thenAnswer((invocation) async => invocation.positionalArguments[0]);

      when(mockAttendanceRepository.readAllAttendances())
          .thenAnswer((_) async => []);

      final result = await controller.submitAttendance('Test User');

      expect(result, true);
      verify(mockAttendanceRepository.create(any)).called(1);
      verify(mockNotificationService.showSnackbar(any, any, snackPosition: anyNamed('snackPosition'))).called(1);
    });

    test('submitAttendance fails when out of range', () async {
      when(mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => mockPositionFar);

      when(mockLocationService.calculateDistance(any, any, any, any))
          .thenReturn(100.0); // 100 meters (> 50m limit)

      final result = await controller.submitAttendance('Test User');

      expect(result, false);
      verifyNever(mockAttendanceRepository.create(any));
      verify(mockNotificationService.showSnackbar('Out of Range', any, snackPosition: anyNamed('snackPosition'))).called(1);
    });

    test('getListAttendances populates list', () async {
      final attendances = [
        Attendance(name: 'Test', latitude: 0, longitude: 0, createdAt: DateTime.now())
      ];

      when(mockAttendanceRepository.readAllAttendances())
          .thenAnswer((_) async => attendances);

      await controller.getListAttendances();

      expect(controller.listAttendances.length, 1);
      expect(controller.isError.value, false);
    });
  });
}
