import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/appointment.dart';
import '../../data/models/doctor.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import '../../providers/doctor_provider.dart';
import '../doctors/doctor_detail_screen.dart';
import '../doctors/doctors_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

// HomeScreen is the main screen of the app — the first tab in the bottom navigation
// It shows a welcome banner, appointment stats, services, upcoming appointment and top doctors
// It uses DoctorProvider (state management) to share the doctors list with DoctorsScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // DatabaseService reads appointments from SQLite
  final _db   = DatabaseService();
  // AuthService gets the saved user's name from SharedPreferences
  final _auth = AuthService();

  List<Appointment> _appointments = []; // All appointments from SQLite
  String _userName = 'User';             // Logged in user's name
  bool _isLoading  = true;               // True while loading data

  // Services list — each item has a label, icon, color and filter value
  // The filter value matches the specialty field in the Doctor model
  final List<Map<String, dynamic>> _services = [
    {'label': 'Cardiology',  'icon': Icons.favorite_rounded,         'color': Color(0xFF5C6BC0), 'filter': 'Cardiologist'},
    {'label': 'Neurology',   'icon': Icons.psychology_rounded,        'color': Color(0xFF7E57C2), 'filter': 'Neurologist'},
    {'label': 'Orthopedic',  'icon': Icons.accessibility_new_rounded, 'color': Color(0xFF26A69A), 'filter': 'Orthopedic'},
    {'label': 'Dermatology', 'icon': Icons.spa_rounded,               'color': Color(0xFFEC407A), 'filter': 'Dermatologist'},
    {'label': 'Pediatrics',  'icon': Icons.child_care_rounded,        'color': Color(0xFF42A5F5), 'filter': 'Pediatrician'},
    {'label': 'General',     'icon': Icons.medical_services_rounded,  'color': Color(0xFF26C6DA), 'filter': 'General Practitioner'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData(); // Load appointments and doctors when screen opens
  }

  // _today returns today's date as a readable string e.g. "Sunday, June 7, 2026"
  String _today() {
    final now    = DateTime.now();
    final days   = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final months = ['January','February','March','April','May','June','July',
      'August','September','October','November','December'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // _loadData loads everything needed for the HomeScreen
  // 1. Reads appointments from SQLite
  // 2. Gets user name from SharedPreferences
  // 3. Loads doctors via DoctorProvider — shared with DoctorsScreen
  Future<void> _loadData() async {
    final appts = await _db.getAllAppointments();
    final name  = await _auth.getUserName();

    // Load doctors using DoctorProvider — this is Provider state management
    // force:true reloads even if doctors were already loaded
    // DoctorsScreen will also use these same doctors without reloading
    await context.read<DoctorProvider>().loadDoctors(force: true);
    if (!mounted) return;
    setState(() {
      _appointments = appts;
      _userName     = name;
      _isLoading    = false;
    });
  }

  // _cancel updates the appointment status to cancelled in SQLite
  Future<void> _cancel(Appointment a) async {
    await _db.updateAppointment(a.copyWith(status: AppointmentStatus.cancelled));
    await _loadData(); // Reload to update the stats
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled')));
  }

  // _showServiceDoctors shows a bottom sheet with doctors filtered by specialty
  // For example tapping "Cardiology" shows only Cardiologists
  void _showServiceDoctors(Map<String, dynamic> service) {
    final filter   = service['filter'] as String;
    // Read doctors from DoctorProvider — no extra API call needed
    final doctors  = context.read<DoctorProvider>().doctors;
    final filtered = doctors.where((d) => d.specialty == filter).toList();
    final color    = service['color'] as Color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle at top of bottom sheet
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              // Service title with icon
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(service['icon'] as IconData, color: color, size: 20),
                const SizedBox(width: 8),
                Text(service['label'] as String,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
              ]),
              const SizedBox(height: 8),
              // Show message if no doctors available for this specialty
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No doctors available',
                      style: TextStyle(fontFamily: 'Poppins',
                          color: Theme.of(context)
                              .colorScheme.onSurface.withOpacity(0.5))),
                )
              else
              // Show each doctor — tapping navigates to DoctorDetailScreen
                ...filtered.map((d) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                        imageUrl: d.photoUrl,
                        width: 44, height: 44, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.person, color: color, size: 24))),
                  ),
                  title: Text(d.name, style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(d.clinic, style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 12)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14,
                      color: Theme.of(context)
                          .colorScheme.onSurface.withOpacity(0.3)),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => DoctorDetailScreen(doctor: d)));
                  },
                )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // _showAllServices shows a grid of all 6 service categories in a bottom sheet
  void _showAllServices() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('All Services', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 16,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // 3-column grid of service icons
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _services.map((s) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close this sheet
                    _showServiceDoctors(s); // Open doctors sheet for this service
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                              color: (s['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16)),
                          child: Icon(s['icon'] as IconData,
                              color: s['color'] as Color, size: 26)),
                      const SizedBox(height: 6),
                      Text(s['label'] as String,
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme.onSurface.withOpacity(0.7)),
                          textAlign: TextAlign.center),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // context.watch<DoctorProvider>() — this is Provider in action
    // HomeScreen LISTENS to DoctorProvider and rebuilds when doctors change
    final doctorProvider = context.watch<DoctorProvider>();

    // Filter upcoming appointments to show in the upcoming card
    final upcoming = _appointments
        .where((a) => a.status == AppointmentStatus.upcoming).toList();

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData, // Pull down to refresh all data
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // TEAL GRADIENT HEADER — welcome banner with stats
              // Matches the same teal gradient used on the Laravel website
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Welcome text and today's date
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('WELCOME BACK',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                                  color: Colors.white70, letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          // User name from SharedPreferences via AuthService
                          Text(_userName,
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 20,
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(_today(),
                              style: const TextStyle(fontFamily: 'Poppins',
                                  fontSize: 12, color: Colors.white70)),
                        ]),
                        // Book Appointment button — navigates to DoctorsScreen
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const DoctorsScreen())),
                          icon: const Icon(Icons.calendar_month_outlined, size: 16),
                          label: const Text('Book Appointment',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0D9488),
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // STATS CARDS — Total, Pending, Confirmed appointments from SQLite
                    Row(children: [
                      _StatCard(icon: Icons.calendar_today_rounded,
                          label: 'Total',
                          value: _appointments.length.toString()),
                      const SizedBox(width: 10),
                      _StatCard(
                          icon: Icons.access_time_rounded,
                          label: 'Pending',
                          value: _appointments
                              .where((a) => a.status == AppointmentStatus.upcoming)
                              .length.toString()),
                      const SizedBox(width: 10),
                      _StatCard(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Confirmed',
                          value: _appointments
                              .where((a) => a.status == AppointmentStatus.completed)
                              .length.toString()),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SEARCH BAR — tapping navigates to DoctorsScreen with real search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DoctorsScreen())),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: cs.onBackground.withOpacity(0.08))),
                    child: Row(children: [
                      const SizedBox(width: 14),
                      Icon(Icons.search,
                          color: cs.onBackground.withOpacity(0.4), size: 20),
                      const SizedBox(width: 10),
                      Text('Search doctor, clinic...',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                              color: cs.onBackground.withOpacity(0.4))),
                      const Spacer(),
                      Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.tune_rounded,
                              color: Colors.white, size: 16)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // SERVICES SECTION — horizontal scrollable list of medical specialties
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Services', style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 17, fontWeight: FontWeight.bold,
                        color: cs.onBackground)),
                    // "see all" opens a grid of all services in a bottom sheet
                    GestureDetector(
                      onTap: _showAllServices,
                      child: Text('see all', style: TextStyle(fontFamily: 'Poppins',
                          fontSize: 13, color: cs.primary,
                          fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Horizontal scrollable service icons
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _services.length,
                  itemBuilder: (ctx, i) {
                    final s = _services[i];
                    return GestureDetector(
                      // Tap service to show filtered doctors bottom sheet
                      onTap: () => _showServiceDoctors(s),
                      child: Container(
                        width: 80, margin: const EdgeInsets.only(right: 12),
                        child: Column(children: [
                          Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                  color: (s['color'] as Color).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Icon(s['icon'] as IconData,
                                  color: s['color'] as Color, size: 26)),
                          const SizedBox(height: 6),
                          Text(s['label'] as String,
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                                  color: cs.onBackground.withOpacity(0.7)),
                              textAlign: TextAlign.center, maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // UPCOMING APPOINTMENT CARD — shows the nearest upcoming appointment
              // Only shows if there is at least one upcoming appointment
              if (upcoming.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Upcoming Appointment',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 17,
                          fontWeight: FontWeight.bold, color: cs.onBackground)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _UpcomingCard(
                      appointment: upcoming.first, // Show only the first upcoming
                      onCancel: () => _cancel(upcoming.first)),
                ),
                const SizedBox(height: 24),
              ],

              // TOP DOCTORS SECTION — reads from DoctorProvider
              // context.watch<DoctorProvider>() makes this rebuild when doctors load
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Top Doctors', style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 17, fontWeight: FontWeight.bold,
                        color: cs.onBackground)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const DoctorsScreen())),
                      child: Text('see all', style: TextStyle(fontFamily: 'Poppins',
                          fontSize: 13, color: cs.primary,
                          fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Show loading or the top 4 doctors sorted by rating
              // doctorProvider.topDoctors comes from DoctorProvider getter
              doctorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: doctorProvider.topDoctors.length,
                  itemBuilder: (ctx, i) =>
                      _DoctorTile(doctor: doctorProvider.topDoctors[i])),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

// _StatCard is a small card shown in the teal header
// Shows an icon, a number and a label
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: 'Poppins',
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontFamily: 'Poppins',
              fontSize: 10, color: Colors.white70)),
        ]),
      ),
    );
  }
}

// _UpcomingCard shows the next upcoming appointment in the home screen
// Has a cancel button that calls _cancel in HomeScreen
class _UpcomingCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onCancel;
  const _UpcomingCard({required this.appointment, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withBlue(220)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        // Doctor photo with fallback
        ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: appointment.doctorPhotoUrl.isNotEmpty
                ? CachedNetworkImage(
                imageUrl: appointment.doctorPhotoUrl,
                width: 56, height: 56, fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _fallback())
                : _fallback()),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appointment.doctorName,
              style: const TextStyle(fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold, fontSize: 15,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(appointment.doctorSpecialty,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                  color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.access_time, size: 12, color: Colors.white70),
            const SizedBox(width: 4),
            Text('${appointment.date}  •  ${appointment.time}',
                style: const TextStyle(fontFamily: 'Poppins',
                    fontSize: 11, color: Colors.white70)),
          ]),
        ])),
        // X button to cancel the appointment
        IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded,
                color: Colors.white70, size: 20)),
      ]),
    );
  }

  // Fallback widget when doctor photo is not available
  Widget _fallback() => Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.person, color: Colors.white, size: 28));
}

// _DoctorTile shows a single doctor in the Top Doctors list
// Tapping navigates to DoctorDetailScreen
class _DoctorTile extends StatelessWidget {
  final Doctor doctor;
  const _DoctorTile({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doctor))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.onBackground.withOpacity(0.07))),
        child: Row(children: [
          // Doctor photo
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                  imageUrl: doctor.photoUrl,
                  width: 64, height: 64, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                      width: 64, height: 64,
                      color: cs.primary.withOpacity(0.1),
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, __, ___) => Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.person, color: cs.primary, size: 32)))),
          const SizedBox(width: 14),
          // Doctor info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doctor.name, style: TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
            const SizedBox(height: 3),
            Text(doctor.specialty, style: TextStyle(fontFamily: 'Poppins',
                fontSize: 12, color: cs.onSurface.withOpacity(0.5))),
            const SizedBox(height: 5),
            Row(children: [
              Icon(Icons.access_time_outlined, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(doctor.experience.isNotEmpty
                  ? doctor.experience : '10:30 AM - 3:30 PM',
                  style: TextStyle(fontFamily: 'Poppins',
                      fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
            ]),
            if (doctor.consultationFee.isNotEmpty)
              Text('Fee: ${doctor.consultationFee}',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                      color: cs.onSurface.withOpacity(0.4))),
          ])),
          // Rating and arrow
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
              const SizedBox(width: 2),
              Text(doctor.rating.toStringAsFixed(1),
                  style: const TextStyle(fontFamily: 'Poppins',
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 14),
            Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 16)),
          ]),
        ]),
      ),
    );
  }
}