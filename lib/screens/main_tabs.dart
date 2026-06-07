import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:medislot/screens/home/home_screen.dart';
import 'package:medislot/screens/doctors/doctors_screen.dart';
import 'package:medislot/screens/appointments/appointments_screen.dart';
import 'package:medislot/screens/profile/profile_screen.dart';

// MainTabs is the main navigation screen of the app
// It contains the 4 bottom navigation tabs and the offline banner
// It also demonstrates the network connectivity mobile device capability
// using the connectivity_plus package
class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  // Tracks which tab is currently selected — 0=Home, 1=Schedule, 2=Saved, 3=Profile
  int _currentIndex = 0;

  // Tracks whether the device has internet connection
  // Used to show or hide the offline red banner
  bool _isOnline = true;

  // The 4 screens for each bottom navigation tab
  final List<Widget> _screens = const [
    HomeScreen(),        // Tab 0 — Home
    DoctorsScreen(),     // Tab 1 — Schedule (Doctors List)
    AppointmentsScreen(),// Tab 2 — Saved (Appointments)
    ProfileScreen(),     // Tab 3 — Profile
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity(); // Check internet connection on app start

    // Listen for network changes in real time using connectivity_plus
    // This fires whenever the device connects or disconnects from internet
    // In v6 of connectivity_plus, the result is a List not a single value
    Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;
      setState(() {
        // Check if any connection type is active (wifi, mobile data or ethernet)
        _isOnline = results.any((r) =>
        r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet);
      });
    });
  }

  // _checkConnectivity checks the current connection status when the app starts
  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      _isOnline = results.any((r) =>
      r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // OFFLINE BANNER — only shows when there is no internet connection
          // When offline, the app automatically uses local JSON for doctors data
          // This satisfies the requirement: "network connectivity information"
          if (!_isOnline)
            SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: Colors.red.shade700,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('No internet — showing offline data',
                        style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ),

          // The currently selected screen fills the rest of the space
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),

      // BOTTOM NAVIGATION BAR — custom built with 4 tabs
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    currentIndex: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month_rounded,
                    label: 'Schedule',
                    index: 1,
                    currentIndex: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.favorite_outline_rounded,
                    activeIcon: Icons.favorite_rounded,
                    label: 'Saved',
                    index: 2,
                    currentIndex: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    index: 3,
                    currentIndex: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// _NavItem is a single tab button in the bottom navigation bar
// It shows a different icon and color when selected vs unselected
class _NavItem extends StatelessWidget {
  final IconData icon;       // Icon when not selected
  final IconData activeIcon; // Icon when selected (filled version)
  final String label;        // Text label below the icon
  final int index;           // This tab's index
  final int currentIndex;    // The currently active tab index
  final void Function(int) onTap; // Called when this tab is tapped

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs         = Theme.of(context).colorScheme;
    final isSelected = index == currentIndex; // True if this is the active tab

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque, // Makes the whole area tappable
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container — teal background when selected, transparent when not
            Container(
              width: 48, height: 36,
              decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.12) // Light teal highlight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(
                  isSelected ? activeIcon : icon, // Filled icon when selected
                  color: isSelected
                      ? cs.primary                          // Teal when selected
                      : cs.onSurface.withValues(alpha: 0.4), // Grey when not
                  size: 22),
            ),
            const SizedBox(height: 2),
            // Tab label — bold and teal when selected
            Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.4))),
          ],
        ),
      ),
    );
  }
}