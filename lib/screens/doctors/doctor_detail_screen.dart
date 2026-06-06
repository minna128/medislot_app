import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/doctor.dart';
import '../booking/booking_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  String? _selectedSlot;

  static const List<String> _timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final doctor = widget.doctor;
    final textColor = cs.onSurface;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF0D9488),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  doctor.photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: doctor.photoUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF0D9488).withOpacity(0.2),
                            child: const Icon(Icons.person, size: 100,
                                color: Color(0xFF0D9488)),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF0D9488).withOpacity(0.2),
                          child: const Icon(Icons.person, size: 100,
                              color: Color(0xFF0D9488)),
                        ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [cs.surface, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctor.name,
                                style: TextStyle(fontFamily: 'Poppins',
                                    fontSize: 22, fontWeight: FontWeight.bold,
                                    color: textColor)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF0D9488).withOpacity(0.3)),
                              ),
                              child: Text(doctor.specialty,
                                  style: const TextStyle(fontFamily: 'Poppins',
                                      fontSize: 12, fontWeight: FontWeight.w600,
                                      color: Color(0xFF0D9488))),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(doctor.rating.toStringAsFixed(1),
                              style: TextStyle(fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15, color: textColor)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Color(0xFF0D9488)),
                    const SizedBox(width: 6),
                    Flexible(child: Text(
                        doctor.clinic.isNotEmpty ? doctor.clinic : 'MediSlot Clinic',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                            color: textColor.withOpacity(0.7)))),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.access_time_outlined,
                        size: 16, color: Color(0xFF5C6BC0)),
                    const SizedBox(width: 6),
                    Flexible(child: Text(
                        doctor.experience.isNotEmpty ? doctor.experience : 'Mon-Fri 9am-5pm',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                            color: textColor.withOpacity(0.7)))),
                  ]),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(value: '5+', label: 'Years\nExp'),
                        Container(width: 1, height: 40,
                            color: Colors.white.withOpacity(0.3)),
                        _StatItem(value: '200+', label: 'Patients\nTreated'),
                        Container(width: 1, height: 40,
                            color: Colors.white.withOpacity(0.3)),
                        _StatItem(
                            value: doctor.rating.toStringAsFixed(1),
                            label: 'Patient\nRating'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (doctor.bio.isNotEmpty) ...[
                    Text('About', style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: textColor)),
                    const SizedBox(height: 8),
                    Text(doctor.bio,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                            height: 1.6, color: textColor.withOpacity(0.7))),
                    const SizedBox(height: 20),
                  ],

                  Text('Available Time Slots',
                      style: TextStyle(fontFamily: 'Poppins',
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _timeSlots.map((slot) {
                      final isSelected = _selectedSlot == slot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSlot = slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0D9488)
                                : const Color(0xFF0D9488).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF0D9488).withOpacity(
                                    isSelected ? 1.0 : 0.3)),
                          ),
                          child: Text(slot,
                              style: TextStyle(fontFamily: 'Poppins',
                                  fontSize: 13, fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF0D9488))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedSlot == null ? null : () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => BookingScreen(
                                doctor: doctor,
                                timeSlot: _selectedSlot!)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontFamily: 'Poppins',
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: Text(_selectedSlot == null
                          ? 'Select a Time Slot'
                          : 'Book — $_selectedSlot'),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: const TextStyle(fontFamily: 'Poppins',
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontFamily: 'Poppins',
          fontSize: 11, color: Colors.white70, height: 1.4),
          textAlign: TextAlign.center),
    ]);
  }
}