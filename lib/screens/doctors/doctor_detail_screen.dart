import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/appointment.dart';
import '../../data/models/doctor.dart';
import '../../data/services/database_service.dart';
import '../booking/booking_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

// DoctorDetailScreen shows full details of a selected doctor
// It demonstrates 2 mobile device capabilities:
// 1. GPS (geolocator) — calculates distance from user to clinic
// 2. Maps (url_launcher) — opens Google Maps when clinic name is tapped
// It also reads from SQLite to show which time slots are already booked
class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor; // The doctor passed from the doctors list
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {

  // _getAvailableSlots filters the full time slots list to only show
  // slots within the doctor's working hours
  // For example if a doctor works "9am-5pm", slots before 9am and after 5pm are hidden
  List<String> _getAvailableSlots() {
    final availability = widget.doctor.experience.toLowerCase();

    // Use RegEx to extract the start and end times from the availability string
    // e.g. "Mon-Fri 9am-5pm" → start: 9am, end: 5pm
    final timeRegex = RegExp(r'(\d+)(?::(\d+))?(am|pm)\s*-\s*(\d+)(?::(\d+))?(am|pm)');
    final match = timeRegex.firstMatch(availability);

    // If we can't parse the hours, return all time slots
    if (match == null) return _timeSlots;

    int startHour   = int.parse(match.group(1)!);
    final startPeriod = match.group(3)!;
    int endHour     = int.parse(match.group(4)!);
    final endPeriod = match.group(6)!;

    // Convert from 12-hour to 24-hour format for comparison
    if (startPeriod == 'pm' && startHour != 12) startHour += 12;
    if (startPeriod == 'am' && startHour == 12) startHour = 0;
    if (endPeriod == 'pm' && endHour != 12) endHour += 12;
    if (endPeriod == 'am' && endHour == 12) endHour = 0;

    // Filter time slots — only keep slots within working hours
    return _timeSlots.where((slot) {
      final parts     = slot.split(' ');
      final timeParts = parts[0].split(':');
      int hour        = int.parse(timeParts[0]);
      final isPM      = parts[1] == 'PM';
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return hour >= startHour && hour < endHour;
    }).toList();
  }

  // _bookedSlots stores the time slots already booked with this doctor
  // These will be shown in grey and cannot be selected
  List<String> _bookedSlots = [];

  String? _selectedSlot;   // The time slot the user has tapped
  String _distanceText = ''; // Stores the calculated distance e.g. "136.7 km from you"

  // All possible time slots from 8am to 5:30pm in 30-minute intervals
  // _getAvailableSlots() filters this list based on doctor's working hours
  static const List<String> _timeSlots = [
    '08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM',
    '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
  ];

  // Hardcoded coordinates for each clinic in Sri Lanka
  // Used to calculate distance and open Google Maps
  static const Map<String, List<double>> _clinicCoords = {
    'Heart Care Clinic':    [7.2906, 80.6337], // Kandy
    'Kids Health Clinic':   [6.0535, 80.2210], // Galle
    'Neuro Care Center':    [6.9271, 79.8612], // Colombo
    'Skin Wellness Clinic': [6.0535, 80.2210], // Galle
    'MediSlot Main Clinic': [6.9271, 79.8612], // Colombo
    'MediSlot Clinic':      [7.2906, 80.6337], // Kandy
    'Block A':              [7.2810, 80.6380], // Kandy
    'Block B':              [7.2820, 80.6390], // Kandy
  };

  @override
  void initState() {
    super.initState();
    _getDistance();      // Start GPS calculation when screen opens
    _loadBookedSlots();  // Load already booked slots from SQLite
  }

  // _loadBookedSlots reads from SQLite to find which time slots
  // are already booked with this doctor
  // These slots are shown in grey and cannot be selected
  Future<void> _loadBookedSlots() async {
    final db           = DatabaseService();
    final appointments = await db.getAllAppointments();
    if (!mounted) return;
    setState(() {
      // Filter appointments for this doctor with upcoming status
      // and extract just the time strings
      _bookedSlots = appointments
          .where((a) =>
      a.doctorName == widget.doctor.name &&
          a.status == AppointmentStatus.upcoming)
          .map((a) => a.time)
          .toList();
    });
  }

  // _findCoords finds the coordinates for a clinic name
  // First tries exact match, then tries partial match
  // e.g. "Block B, MediSlot Clinic" matches "Block B" key
  List<double>? _findCoords(String clinicName) {
    // Try exact match first
    if (_clinicCoords.containsKey(clinicName)) return _clinicCoords[clinicName];

    // Try partial match — find the most specific key that is contained in the clinic name
    String? bestKey;
    int bestLen = 0;
    for (final key in _clinicCoords.keys) {
      if (clinicName.contains(key) && key.length > bestLen) {
        bestKey = key;
        bestLen = key.length;
      }
    }
    return bestKey != null ? _clinicCoords[bestKey] : null;
  }

  // _getDistance uses the GPS sensor to get the user's current location
  // Then calculates the distance to the clinic in kilometres
  // This demonstrates the geolocation mobile device capability
  Future<void> _getDistance() async {
    try {
      // Check if location services (GPS) are turned on
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _distanceText = 'Location off');
        return;
      }

      // Check if the app has permission to access location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Ask the user for location permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _distanceText = 'Permission denied');
          return;
        }
      }

      // Get the user's current GPS coordinates
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low)
          .timeout(const Duration(seconds: 10));

      // Find the clinic's coordinates from our hardcoded map
      final coords = _findCoords(widget.doctor.clinic);
      if (coords == null) {
        setState(() => _distanceText = '');
        return;
      }

      // Calculate distance in metres between user and clinic
      // Geolocator.distanceBetween uses the Haversine formula
      final distance = Geolocator.distanceBetween(
          position.latitude, position.longitude,
          coords[0], coords[1]);

      // Convert metres to kilometres and show on screen
      final km = (distance / 1000).toStringAsFixed(1);
      setState(() => _distanceText = '$km km from you');
    } catch (e) {
      // If anything fails, just hide the distance text
      setState(() => _distanceText = '');
    }
  }

  // _openInMaps opens Google Maps with the clinic's coordinates
  // Uses url_launcher package to launch the external Maps app
  Future<void> _openInMaps() async {
    final coords = _findCoords(widget.doctor.clinic);
    if (coords == null) return;

    final lat   = coords[0];
    final lng   = coords[1];
    final label = Uri.encodeComponent(widget.doctor.clinic);

    // Build Google Maps URL with the clinic's coordinates
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$label');

    // Open the URL in the external Google Maps app
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final doctor   = widget.doctor;
    final textColor = cs.onSurface;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // COLLAPSIBLE APP BAR with doctor's photo as background
          // SliverAppBar expands to show the photo and collapses when scrolling
          SliverAppBar(
            expandedHeight: 300,
            pinned: true, // AppBar stays visible when collapsed
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
                  // Doctor photo — loaded from AWS server using CachedNetworkImage
                  // CachedNetworkImage caches the photo so it doesn't reload every time
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
                  // Gradient fade at the bottom so content below blends in
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

          // MAIN CONTENT below the photo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor name and specialty badge
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
                            // Specialty badge with teal background
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
                      // Star rating badge
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

                  // CLINIC NAME — tappable, opens Google Maps
                  // Underline and arrow icon shows it is clickable
                  GestureDetector(
                    onTap: () async => await _openInMaps(),
                    child: Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Color(0xFF0D9488)),
                      const SizedBox(width: 6),
                      Flexible(child: Text(
                          doctor.clinic.isNotEmpty
                              ? doctor.clinic : 'MediSlot Clinic',
                          style: const TextStyle(fontFamily: 'Poppins',
                              fontSize: 13, color: Color(0xFF0D9488),
                              decoration: TextDecoration.underline))),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new_rounded,
                          size: 12, color: Color(0xFF0D9488)),
                    ]),
                  ),

                  // GPS DISTANCE — shows how far the clinic is from the user
                  // Only shows if GPS calculation was successful
                  if (_distanceText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.near_me_outlined,
                          size: 14, color: Color(0xFF0D9488)),
                      const SizedBox(width: 6),
                      Text(_distanceText,
                          style: const TextStyle(fontFamily: 'Poppins',
                              fontSize: 12, color: Color(0xFF0D9488),
                              fontWeight: FontWeight.w500)),
                    ]),
                  ],
                  const SizedBox(height: 6),

                  // Working hours row
                  Row(children: [
                    const Icon(Icons.access_time_outlined,
                        size: 16, color: Color(0xFF5C6BC0)),
                    const SizedBox(width: 6),
                    Flexible(child: Text(
                        doctor.experience.isNotEmpty
                            ? doctor.experience : 'Mon-Fri 9am-5pm',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13,
                            color: textColor.withOpacity(0.7)))),
                  ]),
                  const SizedBox(height: 20),

                  // STATS CARD — teal gradient showing years, patients, rating
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

                  // ABOUT SECTION — doctor's bio
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

                  // TIME SLOTS SECTION
                  Text('Available Time Slots',
                      style: TextStyle(fontFamily: 'Poppins',
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 6),
                  // Show doctor's working hours above the time slots
                  if (doctor.experience.isNotEmpty)
                    Text('Working hours: ${doctor.experience}',
                        style: const TextStyle(fontFamily: 'Poppins',
                            fontSize: 12, color: Color(0xFF0D9488))),
                  const SizedBox(height: 12),

                  // TIME SLOT GRID — shows only slots within working hours
                  // Teal = available, Grey = already booked, Solid teal = selected
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _getAvailableSlots().map((slot) {
                      final isSelected = _selectedSlot == slot;
                      final isBooked   = _bookedSlots.contains(slot);
                      return GestureDetector(
                        // Cannot tap a booked slot
                        onTap: isBooked
                            ? null
                            : () => setState(() => _selectedSlot = slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            // Grey if booked, solid teal if selected, light teal if available
                            color: isBooked
                                ? Colors.grey.withOpacity(0.1)
                                : isSelected
                                ? const Color(0xFF0D9488)
                                : const Color(0xFF0D9488).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: isBooked
                                    ? Colors.grey.withOpacity(0.3)
                                    : const Color(0xFF0D9488).withOpacity(
                                    isSelected ? 1.0 : 0.3)),
                          ),
                          child: Text(slot,
                              style: TextStyle(fontFamily: 'Poppins',
                                  fontSize: 13, fontWeight: FontWeight.w500,
                                  color: isBooked
                                      ? Colors.grey
                                      : isSelected
                                      ? Colors.white
                                      : const Color(0xFF0D9488))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // BOOK BUTTON — only active when a time slot is selected
                  // Passes the selected doctor and time slot to BookingScreen
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedSlot == null
                          ? null // Disabled until a slot is selected
                          : () {
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

// _StatItem is a small widget used in the stats card
// Shows a value and a label e.g. "5+" and "Years Exp"
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