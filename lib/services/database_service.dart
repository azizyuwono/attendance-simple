import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
import '../models/attendance.dart'; // Needed for table creation schema

class DatabaseService extends GetxService {
  late Database _database;

  Future<DatabaseService> init() async {
    _database = await _initDB(AppConstants.dbName);
    return this;
  }

  Database get database => _database;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Simple migration: drop and recreate to fix schema
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableAttendances}');
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL'; // Fixed: createdAt should be TEXT for ISO8601
    const doubleType = 'DOUBLE NOT NULL';

    await db.execute(
        '''
        CREATE TABLE ${AppConstants.tableAttendances} (
          ${AttendanceFields.id} $idType,   
          ${AttendanceFields.name} $textType,
          ${AttendanceFields.latitude} $doubleType,
          ${AttendanceFields.longitude} $doubleType,
          ${AttendanceFields.createdAt} $textType
          )
    ''');
  }

  Future<void> close() async {
    await _database.close();
  }
}
