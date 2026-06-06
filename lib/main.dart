import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/doctor_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main_tabs.dart';

void main() {
  runApp(
    // MultiProvider wraps the whole app so any screen can access these providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      child: const MediSlotApp(),
    ),
  );
}

class MediSlotApp extends StatelessWidget {
  const MediSlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediSlot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppStartup(),
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Load user data into AuthProvider on startup
    await context.read<AuthProvider>().loadUser();
    if (!mounted) return;
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const MainTabs() : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

