import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.person, size: 52, color: cs.primary)),
            const SizedBox(height: 16),

            Text(auth.userName,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Text(auth.userEmail,
                style: TextStyle(fontFamily: 'Poppins',
                    color: cs.onSurface.withOpacity(0.5))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(auth.userRole.toUpperCase(),
                  style: TextStyle(fontFamily: 'Poppins',
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: cs.primary)),
            ),

            const SizedBox(height: 32),

            Card(
              child: Column(children: [
                _ProfileTile(icon: Icons.person_outline,
                    label: 'Full Name', value: auth.userName),
                const Divider(height: 1, indent: 56),
                _ProfileTile(icon: Icons.email_outlined,
                    label: 'Email', value: auth.userEmail),
                const Divider(height: 1, indent: 56),
                _ProfileTile(icon: Icons.badge_outlined,
                    label: 'Role', value: auth.userRole),
              ]),
            ),

            const SizedBox(height: 16),

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

            OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false);
              },
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