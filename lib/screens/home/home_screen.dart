import 'package:flutter/material.dart';
import '../../data/models/appointment.dart';
import '../../data/models/doctor.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import '../../data/services/doctor_service.dart';
import '../doctors/doctor_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService();
  final _auth = AuthService();
  final _doctorService = DoctorService();
  List<Appointment> _appointments = [];
  List<Doctor> _doctors = [];
  String _userName = 'User';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _services = [
    {'label': 'Cardiology',  'icon': Icons.favorite_rounded,         'color': Color(0xFF5C6BC0), 'filter': 'Cardiologist'},
    {'label': 'Neurology',   'icon': Icons.psychology_rounded,        'color': Color(0xFF7E57C2), 'filter': 'Neurologist'},
    {'label': 'Orthopedic',  'icon': Icons.accessibility_new_rounded, 'color': Color(0xFF26A69A), 'filter': 'Orthopedic'},
    {'label': 'Dermatology', 'icon': Icons.spa_rounded,               'color': Color(0xFFEC407A), 'filter': 'Dermatologist'},
    {'label': 'Paediatrics', 'icon': Icons.child_care_rounded,        'color': Color(0xFF42A5F5), 'filter': 'Paediatrician'},
    {'label': 'General',     'icon': Icons.medical_services_rounded,  'color': Color(0xFF26C6DA), 'filter': 'General Practitioner'},
  ];

  @override
  void initState() { super.initState(); _loadData(); }

  String _today() {
    final now = DateTime.now();
    final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<void> _loadData() async {
    final appts   = await _db.getAllAppointments();
    final name    = await _auth.getUserName();
    final doctors = await _doctorService.getDoctors();
    if (!mounted) return;
    setState(() {
      _appointments = appts;
      _userName     = name;
      _doctors      = doctors;
      _isLoading    = false;
    });
  }

  Future<void> _cancel(Appointment a) async {
    await _db.updateAppointment(a.copyWith(status: AppointmentStatus.cancelled));
    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled')));
  }

  void _showServiceDoctors(Map<String, dynamic> service) {
    final filter = service['filter'] as String;
    final filtered = _doctors.where((d) => d.specialty == filter).toList();
    final color = service['color'] as Color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(service['icon'] as IconData, color: color, size: 20),
            const SizedBox(width: 8),
            Text(service['label'] as String,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
          ]),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No doctors available',
                  style: TextStyle(fontFamily: 'Poppins',
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            )
          else
            ...filtered.map((d) => ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                    imageUrl: d.photoUrl, width: 44, height: 44, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.person, color: color, size: 24))),
              ),
              title: Text(d.name, style: const TextStyle(fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(d.clinic, style: const TextStyle(fontFamily: 'Poppins',
                  fontSize: 12)),
              trailing: Icon(Icons.arrow_forward_ios, size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: d)));
              },
            )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final upcoming = _appointments
        .where((a) => a.status == AppointmentStatus.upcoming).toList();

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Teal gradient welcome banner
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
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('WELCOME BACK',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                                  color: Colors.white70, letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(_userName,
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 20,
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(_today(),
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12,
                                  color: Colors.white70)),
                        ]),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_month_outlined, size: 16),
                          label: const Text('Book Appointment',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0D9488),
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      _StatCard(icon: Icons.calendar_today_rounded,
                          label: 'Total', value: _appointments.length.toString()),
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

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.onBackground.withOpacity(0.08))),
                  child: Row(children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search, color: cs.onBackground.withOpacity(0.4), size: 20),
                    const SizedBox(width: 10),
                    Text('Search doctor, clinic...',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                            color: cs.onBackground.withOpacity(0.4))),
                    const Spacer(),
                    Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: cs.primary, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 16)),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              // Services
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Services', style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 17, fontWeight: FontWeight.bold, color: cs.onBackground)),
                    Text('see all', style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 13, color: cs.primary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _services.length,
                  itemBuilder: (ctx, i) {
                    final s = _services[i];
                    return GestureDetector(
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

              // Upcoming appointment
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
                  child: _UpcomingCard(appointment: upcoming.first,
                      onCancel: () => _cancel(upcoming.first)),
                ),
                const SizedBox(height: 24),
              ],

              // Top Doctors
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Top Doctors', style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 17, fontWeight: FontWeight.bold, color: cs.onBackground)),
                    Text('see all', style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 13, color: cs.primary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _doctors.length,
                  itemBuilder: (ctx, i) => _DoctorTile(doctor: _doctors[i])),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

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
              colors: [Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withBlue(220)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: appointment.doctorPhotoUrl.isNotEmpty
                ? CachedNetworkImage(imageUrl: appointment.doctorPhotoUrl,
                width: 56, height: 56, fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _fallback())
                : _fallback()),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appointment.doctorName,
              style: const TextStyle(fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
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
        IconButton(onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20)),
      ]),
    );
  }
  Widget _fallback() => Container(
      width: 56, height: 56,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.person, color: Colors.white, size: 28));
}

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
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(imageUrl: doctor.photoUrl,
                  width: 64, height: 64, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(width: 64, height: 64,
                      color: cs.primary.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, __, ___) => Container(width: 64, height: 64,
                      decoration: BoxDecoration(color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.person, color: cs.primary, size: 32)))),
          const SizedBox(width: 14),
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
              Text(doctor.experience.isNotEmpty ? doctor.experience : '10:30 AM - 3:30 PM',
                  style: TextStyle(fontFamily: 'Poppins',
                      fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
            ]),
            if (doctor.consultationFee.isNotEmpty)
              Text('Fee: ${doctor.consultationFee}',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                      color: cs.onSurface.withOpacity(0.4))),
          ])),
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
                decoration: BoxDecoration(color: cs.primary,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 16)),
          ]),
        ]),
      ),
    );
  }
}
