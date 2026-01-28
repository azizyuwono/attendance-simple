import 'package:attendanceapp/constants/app_constants.dart';
import 'package:attendanceapp/models/attendance.dart';
import 'package:attendanceapp/repository/attendance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../test_helper.mocks.dart';

void main() {
  late AttendanceRepository repository;
  late MockDatabaseService mockDatabaseService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockDatabase = MockDatabase();

    when(mockDatabaseService.database).thenReturn(mockDatabase);

    repository = AttendanceRepository(mockDatabaseService);
  });

  group('AttendanceRepository', () {
    final attendance = Attendance(
      name: 'Test',
      latitude: 1.0,
      longitude: 2.0,
      createdAt: DateTime.now(),
    );

    test('create inserts attendance and returns copy with ID', () async {
      when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

      final result = await repository.create(attendance);

      expect(result.id, 1);
      expect(result.name, attendance.name);
      verify(mockDatabase.insert(AppConstants.tableAttendances, any)).called(1);
    });

    test('readAllAttendances returns list of attendances', () async {
      final json = attendance.toJson();
      json[AttendanceFields.id] = 1;
      // createdAt in json is string

      when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
          .thenAnswer((_) async => [json]);

      final result = await repository.readAllAttendances();

      expect(result.length, 1);
      expect(result.first.id, 1);
      verify(mockDatabase.query(AppConstants.tableAttendances, orderBy: '${AttendanceFields.createdAt} DESC')).called(1);
    });
  });
}
