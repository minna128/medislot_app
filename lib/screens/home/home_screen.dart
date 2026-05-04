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
    {'label': 'Cardiology',  'icon': Icons.favorite_rounded,        'color': Color(0xFF5C6BC0)},
    {'label': 'Neurology',   'icon': Icons.psychology_rounded,       'color': Color(0xFF7E57C2)},
    {'label': 'Dentistry',   'icon': Icons.medical_services_rounded, 'color': Color(0xFF42A5F5)},
    {'label': 'Orthopedic',  'icon': Icons.accessibility_new_rounded,'color': Color(0xFF26A69A)},
  ];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final appts   = await _db.getAllAppointments();
    final name    = await _auth.getUserName();
    final doctors = await _doctorService.getDoctors();
    if (!mounted) return;
    setState(() {
      _appointments = appts;
      _userName     = name.split(' ').first;
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
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20,16,20,0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Hello $_userName !',
                          style: TextStyle(fontFamily:'Poppins', fontSize:22,
                              fontWeight:FontWeight.bold, color:cs.onBackground)),
                      Text('How are you today?',
                          style: TextStyle(fontFamily:'Poppins', fontSize:13,
                              color:cs.onBackground.withOpacity(0.5))),
                    ]),
                    Container(
                        width:44, height:44,
                        decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color:cs.onBackground.withOpacity(0.1))),
                        child: Icon(Icons.notifications_outlined, color:cs.primary, size:22)),
                  ],
                ),
              ),
              const SizedBox(height:20),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:20),
                child: Container(
                  height:50,
                  decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color:cs.onBackground.withOpacity(0.08))),
                  child: Row(children: [
                    const SizedBox(width:14),
                    Icon(Icons.search, color:cs.onBackground.withOpacity(0.4), size:20),
                    const SizedBox(width:10),
                    Text('Search doctor, clinic...',
                        style: TextStyle(fontFamily:'Poppins', fontSize:14,
                            color:cs.onBackground.withOpacity(0.4))),
                    const Spacer(),
                    Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: cs.primary, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.tune_rounded, color:Colors.white, size:16)),
                  ]),
                ),
              ),
              const SizedBox(height:24),

              // Services header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Services', style: TextStyle(fontFamily:'Poppins',
                        fontSize:17, fontWeight:FontWeight.bold, color:cs.onBackground)),
                    Text('see all', style: TextStyle(fontFamily:'Poppins',
                        fontSize:13, color:cs.primary, fontWeight:FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height:14),

              // Service icons
              SizedBox(
                height:90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal:20),
                  itemCount: _services.length,
                  itemBuilder: (ctx, i) {
                    final s = _services[i];
                    return Container(
                      width:80, margin: const EdgeInsets.only(right:12),
                      child: Column(children: [
                        Container(
                            width:56, height:56,
                            decoration: BoxDecoration(
                                color:(s['color'] as Color).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16)),
                            child: Icon(s['icon'] as IconData,
                                color:s['color'] as Color, size:26)),
                        const SizedBox(height:6),
                        Text(s['label'] as String,
                            style: TextStyle(fontFamily:'Poppins', fontSize:11,
                                color:cs.onBackground.withOpacity(0.7)),
                            textAlign: TextAlign.center, maxLines:1,
                            overflow: TextOverflow.ellipsis),
                      ]),
                    );
                  },
                ),
              ),
              const SizedBox(height:24),

              // Upcoming appointment
              if (upcoming.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20),
                  child: Text('Upcoming Appointment',
                      style: TextStyle(fontFamily:'Poppins', fontSize:17,
                          fontWeight:FontWeight.bold, color:cs.onBackground)),
                ),
                const SizedBox(height:12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20),
                  child: _UpcomingCard(appointment:upcoming.first,
                      onCancel:()=>_cancel(upcoming.first)),
                ),
                const SizedBox(height:24),
              ],

              // Top Doctors header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Top Doctors', style: TextStyle(fontFamily:'Poppins',
                        fontSize:17, fontWeight:FontWeight.bold, color:cs.onBackground)),
                    Text('see all', style: TextStyle(fontFamily:'Poppins',
                        fontSize:13, color:cs.primary, fontWeight:FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height:14),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                  shrinkWrap:true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal:20),
                  itemCount: _doctors.length,
                  itemBuilder: (ctx, i) => _DoctorTile(doctor:_doctors[i])),
              const SizedBox(height:24),
            ]),
          ),
        ),
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
              colors:[Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withBlue(220)],
              begin:Alignment.topLeft, end:Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: appointment.doctorPhotoUrl.isNotEmpty
                ? CachedNetworkImage(imageUrl:appointment.doctorPhotoUrl,
                width:56, height:56, fit:BoxFit.cover,
                errorWidget:(_,__,___) => _fallback())
                : _fallback()),
        const SizedBox(width:14),
        Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text(appointment.doctorName,
              style: const TextStyle(fontFamily:'Poppins',
                  fontWeight:FontWeight.bold, fontSize:15, color:Colors.white)),
          const SizedBox(height:2),
          Text(appointment.doctorSpecialty,
              style: TextStyle(fontFamily:'Poppins', fontSize:12,
                  color:Colors.white.withOpacity(0.8))),
          const SizedBox(height:6),
          Row(children:[
            const Icon(Icons.access_time, size:12, color:Colors.white70),
            const SizedBox(width:4),
            Text('${appointment.date}  •  ${appointment.time}',
                style: const TextStyle(fontFamily:'Poppins',
                    fontSize:11, color:Colors.white70)),
          ]),
        ])),
        IconButton(onPressed:onCancel,
            icon: const Icon(Icons.close_rounded, color:Colors.white70, size:20)),
      ]),
    );
  }
  Widget _fallback() => Container(
      width:56, height:56,
      decoration: BoxDecoration(color:Colors.white.withOpacity(0.2),
          borderRadius:BorderRadius.circular(12)),
      child: const Icon(Icons.person, color:Colors.white, size:28));
}

class _DoctorTile extends StatelessWidget {
  final Doctor doctor;
  const _DoctorTile({required this.doctor});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder:(_) => DoctorDetailScreen(doctor:doctor))),
      child: Container(
        margin: const EdgeInsets.only(bottom:14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color:cs.onBackground.withOpacity(0.07))),
        child: Row(children:[
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(imageUrl:doctor.photoUrl,
                  width:64, height:64, fit:BoxFit.cover,
                  placeholder:(_,__) => Container(width:64,height:64,
                      color:cs.primary.withOpacity(0.1),
                      child:const Center(child:CircularProgressIndicator(strokeWidth:2))),
                  errorWidget:(_,__,___) => Container(width:64,height:64,
                      decoration:BoxDecoration(color:cs.primary.withOpacity(0.1),
                          borderRadius:BorderRadius.circular(12)),
                      child:Icon(Icons.person,color:cs.primary,size:32)))),
          const SizedBox(width:14),
          Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(doctor.name, style:TextStyle(fontFamily:'Poppins',
                fontWeight:FontWeight.w600, fontSize:14, color:cs.onSurface)),
            const SizedBox(height:3),
            Text(doctor.specialty, style:TextStyle(fontFamily:'Poppins',
                fontSize:12, color:cs.onSurface.withOpacity(0.5))),
            const SizedBox(height:5),
            Row(children:[
              Icon(Icons.access_time_outlined,size:12,color:Colors.grey),
              const SizedBox(width:4),
              Text('10:30 AM - 3:30 PM', style:TextStyle(fontFamily:'Poppins',
                  fontSize:11, color:cs.onSurface.withOpacity(0.4))),
            ]),
            Text('Fee: ${doctor.consultationFee}',
                style:TextStyle(fontFamily:'Poppins', fontSize:11,
                    color:cs.onSurface.withOpacity(0.4))),
          ])),
          Column(crossAxisAlignment:CrossAxisAlignment.end, children:[
            Row(children:[
              const Icon(Icons.star_rounded,size:14,color:Colors.amber),
              const SizedBox(width:2),
              Text(doctor.rating.toStringAsFixed(1),
                  style:const TextStyle(fontFamily:'Poppins',
                      fontSize:12, fontWeight:FontWeight.w600)),
            ]),
            const SizedBox(height:14),
            Container(
                width:32, height:32,
                decoration:BoxDecoration(color:cs.primary,
                    borderRadius:BorderRadius.circular(10)),
                child:const Icon(Icons.arrow_forward_rounded,
                    color:Colors.white, size:16)),
          ]),
        ]),
      ),
    );
  }
}