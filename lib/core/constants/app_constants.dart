class AppConstants {
  AppConstants._();

  // External JSON URL (fulfils "connect to internet to get data" requirement)
  static const String externalDoctorsUrl =
      'https://raw.githubusercontent.com/your-username/medislot-data/main/doctors.json';

  // Local JSON asset path (fulfils "read from local JSON file offline" requirement)
  static const String localDoctorsJson = 'assets/data/doctors.json';

  // SharedPreferences keys (studied: saving data with Flutter)
  static const String prefIsLoggedIn   = 'is_logged_in';
  static const String prefUserName     = 'user_name';
  static const String prefUserEmail    = 'user_email';

  // SQLite (studied: saving data with Flutter)
  static const String dbName           = 'medislot.db';
  static const int    dbVersion        = 1;
  static const String tableAppointments = 'appointments';

  // UI
  static const double screenPadding    = 20.0;
  static const double cardRadius       = 16.0;
}
