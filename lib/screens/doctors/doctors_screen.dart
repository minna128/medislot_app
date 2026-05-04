import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/doctor.dart';
import '../../data/services/doctor_service.dart';
import 'doctor_detail_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final _doctorService = DoctorService();
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _doctorService.getDoctors();
      if (!mounted) return;
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load doctors.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        title: const Text('Our Doctors',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: cs.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  setState(() { _isLoading = true; _error = null; });
                  _loadDoctors();
                },
                child: const Text('Retry')),
          ]))
          : RefreshIndicator(
        onRefresh: _loadDoctors,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _doctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _DoctorCard(doctor: _doctors[index]),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => DoctorDetailScreen(doctor: doctor))),
      child: Container(
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
                  width: 72, height: 72, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                      width: 72, height: 72,
                      color: cs.primary.withOpacity(0.1),
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, __, ___) => Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.person, color: cs.primary, size: 36)))),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15, color: cs.onSurface)),
                const SizedBox(height: 4),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(doctor.specialty,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11,
                            fontWeight: FontWeight.w500, color: cs.primary))),
                const SizedBox(height: 6),
                Text(doctor.clinic,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                        color: cs.onSurface.withOpacity(0.5))),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(doctor.rating.toStringAsFixed(1),
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Text(doctor.experience,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                          color: cs.onSurface.withOpacity(0.5))),
                ]),
              ],
            ),
          ),

          Icon(Icons.chevron_right,
              color: cs.onSurface.withOpacity(0.3)),
        ]),
      ),
    );
  }
}