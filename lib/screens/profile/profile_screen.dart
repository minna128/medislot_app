import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../auth/welcome_screen.dart';

// Studied topics: StatefulWidget, saving data (reads & clears SharedPreferences)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _authService.getUserName();
    final email = await _authService.getUserEmail();
    if (!mounted) return;
    setState(() {
      _name = name;
      _email = email;
    });
  }

  Future<void> _logout() async {
    await _authService.logout(); // Clears SharedPreferences
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar circle
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 52, color: colorScheme.primary),
            ),
            const SizedBox(height: 16),

            Text(
              _name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: colorScheme.onBackground.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 32),

            // Profile info card
            Card(
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: _name,
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _email,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings card
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.brightness_6_outlined,
                        color: colorScheme.primary),
                    title: const Text('Theme',
                        style: TextStyle(fontFamily: 'Poppins')),
                    subtitle: const Text('Follows device setting',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                    trailing: Icon(Icons.chevron_right,
                        color: colorScheme.onSurface.withOpacity(0.3)),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Icon(Icons.notifications_outlined,
                        color: colorScheme.primary),
                    title: const Text('Notifications',
                        style: TextStyle(fontFamily: 'Poppins')),
                    trailing: Icon(Icons.chevron_right,
                        color: colorScheme.onSurface.withOpacity(0.3)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(label,
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.5))),
      subtitle: Text(value,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500)),
    );
  }
}
