import '../constants/app_constants.dart';
import '../models/attendance.dart';
import '../services/database_service.dart';

class AttendanceRepository {
  final DatabaseService _databaseService;

  AttendanceRepository(this._databaseService);

  Future<Attendance> create(Attendance attendance) async {
    final db = _databaseService.database;

    final id = await db.insert(AppConstants.tableAttendances, attendance.toJson());
    return attendance.copy(id: id);
  }

  Future<Attendance> readAttendance(int id) async {
    final db = _databaseService.database;

    final maps = await db.query(
      AppConstants.tableAttendances,
      columns: AttendanceFields.values,
      where: '${AttendanceFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Attendance.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Attendance>> readAllAttendances() async {
    final db = _databaseService.database;

    const orderBy = '${AttendanceFields.createdAt} DESC'; // Changed to DESC to show newest first

    final result = await db.query(AppConstants.tableAttendances, orderBy: orderBy);

    return result.map((json) => Attendance.fromJson(json)).toList();
  }
}
