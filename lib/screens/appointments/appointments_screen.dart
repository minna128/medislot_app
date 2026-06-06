import 'package:flutter/material.dart';
import '../../data/models/appointment.dart';
import '../../data/services/database_service.dart';

// Studied topics: StatefulWidget, saving data (reads from SQLite)
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final _dbService = DatabaseService();
  List<Appointment> _all = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _seedAndLoad();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Seed test data for demo purposes
  Future<void> _seedAndLoad() async {
    final existing = await _dbService.getAllAppointments();

    final existingIds = existing.map((a) => a.id).toList();
    if (!existingIds.contains('test_1')) {
      final testData = [
        Appointment(
          id: 'test_1',
          date: 'June 10, 2026',
          time: '09:00 AM',
          doctorName: 'Dr. Sarah Lee',
          doctorSpecialty: 'Cardiologist',
          doctorPhotoUrl: 'https://medi-slot.ddns.net/images/doctors/sarah.jpg',
          clinic: 'Heart Care Clinic',
          status: AppointmentStatus.upcoming,
        ),
        Appointment(
          id: 'test_2',
          date: 'June 12, 2026',
          time: '11:00 AM',
          doctorName: 'Dr. Ahmed Khan',
          doctorSpecialty: 'Neurologist',
          doctorPhotoUrl: 'https://medi-slot.ddns.net/images/doctors/ahmed.jpg',
          clinic: 'Neuro Care Center',
          status: AppointmentStatus.upcoming,
        ),
        Appointment(
          id: 'test_3',
          date: 'May 28, 2026',
          time: '10:30 AM',
          doctorName: 'Dr. James Wong',
          doctorSpecialty: 'General Practitioner',
          doctorPhotoUrl: 'https://medi-slot.ddns.net/images/doctors/james.jpg',
          clinic: 'Heart Care Clinic',
          status: AppointmentStatus.completed,
        ),
        Appointment(
          id: 'test_4',
          date: 'May 20, 2026',
          time: '02:00 PM',
          doctorName: 'Dr. Emily Carter',
          doctorSpecialty: 'Paediatrician',
          doctorPhotoUrl: 'https://medi-slot.ddns.net/images/doctors/emily.jpg',
          clinic: 'Kids Health Clinic',
          status: AppointmentStatus.completed,
        ),
        Appointment(
          id: 'test_5',
          date: 'May 15, 2026',
          time: '03:00 PM',
          doctorName: 'Dr. Olivia Brown',
          doctorSpecialty: 'Dermatologist',
          doctorPhotoUrl: 'https://medi-slot.ddns.net/images/doctors/olivia.jpg',
          clinic: 'Skin Wellness Clinic',
          status: AppointmentStatus.cancelled,
        ),
      ];

      for (final appt in testData) {
        await _dbService.insertAppointment(appt);
      }
    }

    await _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final list = await _dbService.getAllAppointments();
    if (!mounted) return;
    setState(() {
      _all = list;
      _isLoading = false;
    });
  }

  Future<void> _cancel(Appointment a) async {
    await _dbService.updateAppointment(
        a.copyWith(status: AppointmentStatus.cancelled));
    await _loadAppointments();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment cancelled')),
    );
  }

  List<Appointment> get _upcoming =>
      _all.where((a) => a.status == AppointmentStatus.upcoming).toList();
  List<Appointment> get _completed =>
      _all.where((a) => a.status == AppointmentStatus.completed).toList();
  List<Appointment> get _cancelled =>
      _all.where((a) => a.status == AppointmentStatus.cancelled).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: Column(
        children: [
          // Teal header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 0),
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
                const Text('My Appointments',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 22,
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('${_all.length} total appointments',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13,
                        color: Colors.white70)),
                const SizedBox(height: 16),
                // Stats row
                Row(children: [
                  _HeaderStat(label: 'Upcoming', value: _upcoming.length.toString(),
                      icon: Icons.access_time_rounded),
                  const SizedBox(width: 10),
                  _HeaderStat(label: 'Completed', value: _completed.length.toString(),
                      icon: Icons.check_circle_outline_rounded),
                  const SizedBox(width: 10),
                  _HeaderStat(label: 'Cancelled', value: _cancelled.length.toString(),
                      icon: Icons.cancel_outlined),
                ]),
                const SizedBox(height: 12),
                // Tab bar
                TabBar(
                  controller: _tabController,
                  labelStyle: const TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                      fontSize: 13),
                  unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 13),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: 'Upcoming (${_upcoming.length})'),
                    Tab(text: 'Done (${_completed.length})'),
                    Tab(text: 'Cancelled'),
                  ],
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _AppointmentList(
                  appointments: _upcoming,
                  onCancel: _cancel,
                  emptyMessage: 'No upcoming appointments',
                  emptyIcon: Icons.calendar_today_outlined,
                ),
                _AppointmentList(
                  appointments: _completed,
                  emptyMessage: 'No completed appointments',
                  emptyIcon: Icons.check_circle_outline,
                ),
                _AppointmentList(
                  appointments: _cancelled,
                  emptyMessage: 'No cancelled appointments',
                  emptyIcon: Icons.cancel_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _HeaderStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(fontFamily: 'Poppins',
                fontSize: 9, color: Colors.white70)),
          ]),
        ]),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Appointment> appointments;
  final void Function(Appointment)? onCancel;
  final String emptyMessage;
  final IconData emptyIcon;

  const _AppointmentList({
    required this.appointments,
    this.onCancel,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 72, color: cs.onSurface.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 15,
                    color: cs.onSurface.withOpacity(0.4))),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _AppointmentCard(
        appointment: appointments[i],
        onCancel: onCancel != null ? () => onCancel!(appointments[i]) : null,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;

  const _AppointmentCard({required this.appointment, this.onCancel});

  Color _statusColor() {
    switch (appointment.status) {
      case AppointmentStatus.upcoming:  return const Color(0xFF0D9488);
      case AppointmentStatus.completed: return const Color(0xFF2E7D32);
      case AppointmentStatus.cancelled: return const Color(0xFFC62828);
    }
  }

  Color _statusBg() {
    switch (appointment.status) {
      case AppointmentStatus.upcoming:  return const Color(0xFFCCFBF1);
      case AppointmentStatus.completed: return const Color(0xFFE8F5E9);
      case AppointmentStatus.cancelled: return const Color(0xFFFFEBEE);
    }
  }

  String _statusLabel() {
    switch (appointment.status) {
      case AppointmentStatus.upcoming:  return 'Upcoming';
      case AppointmentStatus.completed: return 'Completed';
      case AppointmentStatus.cancelled: return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          // Doctor info row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with initials fallback
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
                  backgroundImage: appointment.doctorPhotoUrl.isNotEmpty
                      ? NetworkImage(appointment.doctorPhotoUrl)
                      : null,
                  child: appointment.doctorPhotoUrl.isEmpty
                      ? Text(appointment.doctorName.substring(4, 5),
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488)))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.doctorName,
                          style: TextStyle(fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600, fontSize: 15,
                              color: cs.onSurface)),
                      const SizedBox(height: 2),
                      Text(appointment.doctorSpecialty,
                          style: const TextStyle(fontFamily: 'Poppins',
                              fontSize: 13, color: Color(0xFF0D9488))),
                      const SizedBox(height: 2),
                      Text(appointment.clinic,
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                              color: cs.onSurface.withOpacity(0.5))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statusLabel(),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                          fontWeight: FontWeight.w600, color: _statusColor())),
                ),
              ],
            ),
          ),

          // Date/time row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14,
                    color: cs.onSurface.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(appointment.date,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        color: cs.onSurface.withOpacity(0.6))),
                const SizedBox(width: 16),
                Icon(Icons.access_time_outlined, size: 14,
                    color: cs.onSurface.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(appointment.time,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        color: cs.onSurface.withOpacity(0.6))),
                const Spacer(),
                if (onCancel != null)
                  GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC62828))),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}