import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value
            ? 'Notifications enabled'
            : 'Notifications disabled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: cs.background,
      body: Column(
        children: [
          // Teal gradient header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 2)),
                  child: const Icon(Icons.person, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(auth.userName,
                    style: const TextStyle(fontFamily: 'Poppins',
                        fontSize: 20, fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(auth.userEmail,
                    style: const TextStyle(fontFamily: 'Poppins',
                        fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(auth.userRole.toUpperCase(),
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Info card
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

                  // Settings card
                  Card(
                    child: Column(children: [
                      ListTile(
                          leading: Icon(Icons.brightness_6_outlined,
                              color: cs.primary),
                          title: const Text('Theme',
                              style: TextStyle(fontFamily: 'Poppins')),
                          subtitle: const Text('Follows device setting',
                              style: TextStyle(
                                  fontFamily: 'Poppins', fontSize: 12)),
                          trailing: Icon(Icons.chevron_right,
                              color: cs.onSurface.withOpacity(0.3)),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text(
                                    'Theme follows your device light/dark mode setting')));
                          }),
                      const Divider(height: 1, indent: 56),
                      SwitchListTile(
                        secondary: Icon(Icons.notifications_outlined,
                            color: cs.primary),
                        title: const Text('Notifications',
                            style: TextStyle(fontFamily: 'Poppins')),
                        subtitle: Text(
                            _notificationsEnabled
                                ? 'Appointment reminders enabled'
                                : 'Notifications disabled',
                            style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 12)),
                        value: _notificationsEnabled,
                        activeColor: cs.primary,
                        onChanged: _toggleNotifications,
                      ),
                    ]),
                  ),

                  const SizedBox(height: 32),

                  OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WelcomeScreen()),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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