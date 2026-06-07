import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/appointment.dart';

// DatabaseService manages the SQLite local database on the device
// SQLite is used to store appointments so they are saved even when the app is closed
// This satisfies the requirement: "read and write data from a local data source"
// I use the sqflite package to work with SQLite in Flutter
class DatabaseService {
  // _db is a static variable — this means only ONE database instance exists
  // across the entire app, no matter how many times DatabaseService is created
  static Database? _db;

  // database is a getter that returns the existing database or creates a new one
  // This is called "lazy initialization" — the database is only created when first needed
  Future<Database> get database async {
    if (_db != null) return _db!; // Return existing database if already open
    _db = await _initDatabase();  // Otherwise create a new one
    return _db!;
  }

  // _initDatabase creates the SQLite database file on the device
  // and sets up the appointments table
  Future<Database> _initDatabase() async {
    // Get the folder where databases are stored on this device
    final dbPath = await getDatabasesPath();
    // Build the full path to the database file e.g. "/data/data/.../medislot.db"
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion, // Database version number — used for migrations
      // onCreate only runs the FIRST time the app is installed
      // It creates the appointments table with all the required columns
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.tableAppointments} (
            id              TEXT PRIMARY KEY,  -- Unique ID for each appointment
            date            TEXT NOT NULL,     -- Date e.g. "June 10, 2026"
            time            TEXT NOT NULL,     -- Time e.g. "09:00 AM"
            doctorName      TEXT NOT NULL,     -- Doctor's name
            doctorSpecialty TEXT NOT NULL,     -- Doctor's specialty
            doctorPhotoUrl  TEXT,              -- Doctor's photo URL (optional)
            clinic          TEXT NOT NULL,     -- Clinic name
            status          TEXT NOT NULL DEFAULT 'upcoming' -- upcoming, completed or cancelled
          )
        ''');
      },
    );
  }

  // insertAppointment saves a new appointment to the database
  // Called when the user confirms a booking in BookingScreen
  // ConflictAlgorithm.replace means if an appointment with the same ID exists,
  // it will be replaced instead of throwing an error
  Future<void> insertAppointment(Appointment appointment) async {
    final db = await database;
    await db.insert(
      AppConstants.tableAppointments,
      appointment.toMap(), // Convert Appointment object to Map for SQLite
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // getAllAppointments reads ALL appointments from the database
  // Called by HomeScreen and AppointmentsScreen to display appointments
  // Results are ordered by date — most recent first
  Future<List<Appointment>> getAllAppointments() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableAppointments,
      orderBy: 'date DESC', // Show most recent appointments first
    );
    // Convert each Map row back into an Appointment object
    return maps.map((m) => Appointment.fromMap(m)).toList();
  }

  // updateAppointment updates an existing appointment in the database
  // I use this when the patient cancels an appointment
  // It finds the appointment by ID and updates its status to "cancelled"
  Future<void> updateAppointment(Appointment appointment) async {
    final db = await database;
    await db.update(
      AppConstants.tableAppointments,
      appointment.toMap(),          // New values to save
      where: 'id = ?',              // Find the row with matching ID
      whereArgs: [appointment.id],  // The ID to search for
    );
  }
}