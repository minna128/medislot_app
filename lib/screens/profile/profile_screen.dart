import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../auth/welcome_screen.dart';

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

  Future<void> _lockSession() async {
    await _authService.lockSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false);
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.person, size: 52, color: cs.primary)),
            const SizedBox(height: 16),

            Text(_name,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Text(_email,
                style: TextStyle(fontFamily: 'Poppins',
                    color: cs.onBackground.withOpacity(0.5))),

            const SizedBox(height: 32),

            // Profile info card
            Card(
              child: Column(children: [
                _ProfileTile(icon: Icons.person_outline,
                    label: 'Full Name', value: _name),
                const Divider(height: 1, indent: 56),
                _ProfileTile(icon: Icons.email_outlined,
                    label: 'Email', value: _email),
              ]),
            ),

            const SizedBox(height: 16),

            // Settings card
            Card(
              child: Column(children: [
                ListTile(
                    leading: Icon(Icons.brightness_6_outlined, color: cs.primary),
                    title: const Text('Theme',
                        style: TextStyle(fontFamily: 'Poppins')),
                    subtitle: const Text('Follows device setting',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                    trailing: Icon(Icons.chevron_right,
                        color: cs.onSurface.withOpacity(0.3))),
                const Divider(height: 1, indent: 56),
                ListTile(
                    leading: Icon(Icons.notifications_outlined, color: cs.primary),
                    title: const Text('Notifications',
                        style: TextStyle(fontFamily: 'Poppins')),
                    trailing: Icon(Icons.chevron_right,
                        color: cs.onSurface.withOpacity(0.3))),
              ]),
            ),

            const SizedBox(height: 32),

            // Lock button — keeps account, fingerprint can unlock
            OutlinedButton.icon(
              onPressed: _lockSession,
              icon: const Icon(Icons.logout),
              label: const Text('Logout',
                  style: TextStyle(fontFamily: 'Poppins')),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
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
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(label,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
              color: cs.onSurface.withOpacity(0.5))),
      subtitle: Text(value,
          style: const TextStyle(fontFamily: 'Poppins',
              fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}