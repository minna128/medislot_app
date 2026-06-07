class AppConstants {
  AppConstants._();

  // Laravel API base URL
  static const String baseUrl = 'https://medi-slot.ddns.net';

  // External JSON URL (scrollable list requirement — reads from real hosted JSON)
  static const String externalDoctorsUrl =
      'https://raw.githubusercontent.com/minna128/medislot_app/main/assets/doctors.json';

  // Local JSON asset path (offline fallback)
  static const String localDoctorsJson = 'assets/data/doctors.json';

  // SharedPreferences keys
  static const String prefIsLoggedIn   = 'is_logged_in';
  static const String prefUserName     = 'user_name';
  static const String prefUserEmail    = 'user_email';
  static const String prefUserRole     = 'user_role';
  static const String prefApiToken     = 'api_token';

  // SQLite
  static const String dbName            = 'medislot.db';
  static const int    dbVersion         = 1;
  static const String tableAppointments = 'appointments';

  // UI
  static const double screenPadding = 20.0;
  static const double cardRadius    = 16.0;
}