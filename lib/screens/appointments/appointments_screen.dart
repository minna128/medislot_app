import 'package:flutter/material.dart';
import '../../data/models/appointment.dart';
import '../../data/services/database_service.dart';
import '../../core/theme/app_colors.dart';

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

  // Studied topic: Tabs in Flutter
  // TabBar for filtering appointments by status
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        // Studied topic: Tabs in Flutter — TabBar inside AppBar
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontFamily: 'Poppins'),
          tabs: [
            Tab(text: 'Upcoming (${_upcoming.length})'),
            Tab(text: 'Done (${_completed.length})'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
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
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon,
                size: 72,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _AppointmentTile(
        appointment: appointments[i],
        onCancel: onCancel != null ? () => onCancel!(appointments[i]) : null,
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;

  const _AppointmentTile({required this.appointment, this.onCancel});

  Color _statusColor() {
    switch (appointment.status) {
      case AppointmentStatus.upcoming:  return AppColors.primaryBlue;
      case AppointmentStatus.completed: return AppColors.success;
      case AppointmentStatus.cancelled: return AppColors.error;
    }
  }

  Color _statusBg() {
    switch (appointment.status) {
      case AppointmentStatus.upcoming:  return AppColors.primaryBluePale;
      case AppointmentStatus.completed: return AppColors.successBg;
      case AppointmentStatus.cancelled: return AppColors.errorBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.doctorName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              appointment.doctorSpecialty,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Detail(
                    icon: Icons.calendar_today_outlined,
                    text: appointment.date),
                const SizedBox(width: 16),
                _Detail(
                    icon: Icons.access_time_outlined,
                    text: appointment.time),
              ],
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancel Appointment'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    textStyle: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Detail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 13,
            color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
