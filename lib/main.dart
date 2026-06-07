import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/doctor_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main_tabs.dart';

// This is a global instance of the notifications plugin
// It is declared here so it can be accessed from NotificationService
// without needing to create a new instance every time
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// initNotifications sets up the notification plugin when the app starts
// It also requests notification permission from the user on Android 13+
Future<void> initNotifications() async {
  // Use the app icon for all notifications
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Ask the user to allow notifications — required on Android 13 and above
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation
  <AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

// main() is the entry point of the Flutter app
// Everything is set up here before the app runs
void main() async {
  // Must be called before any async work in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data — needed for scheduling notifications at specific times
  // For example: scheduling the 30-minute reminder before an appointment
  tz.initializeTimeZones();

  // Set up local notifications
  await initNotifications();

  // MultiProvider wraps the entire app so any screen can access shared state
  // This is the core of Provider state management
  // Think of it as a shared memory bank — screens read and write to it
  // instead of passing data between screens manually
  runApp(
    MultiProvider(
      providers: [
        // AuthProvider — stores who is logged in (name, email, role, token)
        // Used by: HomeScreen, ProfileScreen, LoginScreen, RegisterScreen
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // DoctorProvider — stores the list of doctors loaded from the API
        // Used by: HomeScreen (top doctors) and DoctorsScreen (full list)
        // Both screens share the SAME data — no duplicate API calls
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      child: const MediSlotApp(),
    ),
  );
}

// MediSlotApp is the root widget of the entire application
class MediSlotApp extends StatelessWidget {
  const MediSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediSlot',
      debugShowCheckedModeBanner: false, // Hides the debug banner in the corner

      // Light and dark themes defined in AppTheme
      theme:     AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // ThemeMode.system automatically switches between light and dark
      // based on the phone's display settings
      // This satisfies the requirement: "light and dark mode based on device setting"
      themeMode: ThemeMode.system,

      home: const AppStartup(),
    );
  }
}

// AppStartup is the first screen shown while the app checks login status
// It shows a loading spinner while checking if the user is already logged in
// Then navigates to MainTabs if logged in, or WelcomeScreen if not
class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  @override
  void initState() {
    super.initState();
    _checkLogin(); // Check login status as soon as screen is created
  }

  // _checkLogin reads saved user data from SharedPreferences via AuthProvider
  // If user is logged in → go to MainTabs (home screen with bottom navigation)
  // If user is not logged in → go to WelcomeScreen (login/register options)
  Future<void> _checkLogin() async {
    // Load user data into AuthProvider from SharedPreferences
    await context.read<AuthProvider>().loadUser();
    if (!mounted) return;

    // Check if the user is logged in
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

    // Navigate to the appropriate screen and replace the startup screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const MainTabs() : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show MediSlot logo and loading spinner while checking login
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital_rounded, size: 72,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}