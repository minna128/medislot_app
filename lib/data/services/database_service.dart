import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/appointment.dart';

// Studied topic: saving data with Flutter
// SQLite database service for storing appointments locally on the device
class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        // Create appointments table on first launch
        await db.execute('''
          CREATE TABLE ${AppConstants.tableAppointments} (
            id              TEXT PRIMARY KEY,
            date            TEXT NOT NULL,
            time            TEXT NOT NULL,
            doctorName      TEXT NOT NULL,
            doctorSpecialty TEXT NOT NULL,
            doctorPhotoUrl  TEXT,
            clinic          TEXT NOT NULL,
            status          TEXT NOT NULL DEFAULT 'upcoming'
          )
        ''');
      },
    );
  }

  // INSERT a new appointment
  Future<void> insertAppointment(Appointment appointment) async {
    final db = await database;
    await db.insert(
      AppConstants.tableAppointments,
      appointment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ all appointments
  Future<List<Appointment>> getAllAppointments() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableAppointments,
      orderBy: 'date DESC',
    );
    return maps.map((m) => Appointment.fromMap(m)).toList();
  }

  // UPDATE appointment status (e.g. cancel)
  Future<void> updateAppointment(Appointment appointment) async {
    final db = await database;
    await db.update(
      AppConstants.tableAppointments,
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }
}
