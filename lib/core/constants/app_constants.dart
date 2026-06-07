// AppConstants stores all fixed values used across the app in one place
// This way if a URL or key name changes, we only need to update it here
class AppConstants {
  // Private constructor — prevents anyone from creating an instance of this class
  // All values are static so they can be accessed directly as AppConstants.baseUrl
  AppConstants._();

  // The base URL of our Laravel API hosted on AWS EC2
  // All API calls use this as the starting point
  static const String baseUrl = 'https://medi-slot.ddns.net';

  // URL of the external JSON file hosted on GitHub
  // This is fetched when user taps the "External JSON" toggle in Doctors screen
  // Satisfies the requirement: "connect to internet to get data from external JSON file"
  static const String externalDoctorsUrl =
      'https://raw.githubusercontent.com/minna128/medislot_app/main/assets/doctors.json';

  // Path to the local JSON file stored inside the app
  // Used as offline fallback when there is no internet connection
  // Satisfies the requirement: "provide suitable content read from local JSON if offline"
  static const String localDoctorsJson = 'assets/data/doctors.json';

  // Keys used to save and retrieve user data from SharedPreferences
  // SharedPreferences is like a small key-value store on the device
  // We use it to remember if the user is logged in between app sessions
  static const String prefIsLoggedIn   = 'is_logged_in';
  static const String prefUserName     = 'user_name';
  static const String prefUserEmail    = 'user_email';
  static const String prefUserRole     = 'user_role';
  static const String prefApiToken     = 'api_token'; // Sanctum token for API authentication

  // SQLite database configuration
  // SQLite is the local database used to store appointments on the device
  // Satisfies the requirement: "read and write data from a local data source"
  static const String dbName            = 'medislot.db'; // Database file name
  static const int    dbVersion         = 1;              // Database version number
  static const String tableAppointments = 'appointments'; // Table name for appointments

  // UI constants used for consistent spacing and styling across all screens
  static const double screenPadding = 20.0; // Standard padding for all screens
  static const double cardRadius    = 16.0; // Rounded corner radius for all cards
}