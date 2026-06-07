import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/doctor.dart';
import '../../data/services/doctor_service.dart';
import 'doctor_detail_screen.dart';

// DoctorsScreen shows a scrollable list of all doctors
// This satisfies the requirement: "scrollable list with master/detail"
// Tapping a doctor card goes to DoctorDetailScreen (the detail part)
// It also demonstrates loading from two different data sources:
// 1. Live API — fetches from Laravel backend on AWS
// 2. External JSON — fetches from GitHub hosted JSON file
class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  // DoctorService handles fetching from API, external JSON or local JSON
  final _doctorService = DoctorService();

  // Controller for the search bar text field
  final _searchController = TextEditingController();

  List<Doctor> _doctors  = []; // Full list of doctors loaded from source
  List<Doctor> _filtered = []; // Filtered list based on search query
  bool _isLoading        = true;  // True while loading doctors
  String? _error;                  // Stores error message if loading fails

  // Tracks which data source is currently active
  // false = Live API, true = External JSON (GitHub)
  bool _useExternalJson = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors(); // Load doctors when screen opens
    // Listen for search bar changes — filter list as user types
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    // Always dispose the search controller to free memory
    _searchController.dispose();
    super.dispose();
  }

  // _onSearch filters the doctors list in real time as the user types
  // It checks if the query matches the doctor's name, specialty or clinic
  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _doctors.where((d) =>
      d.name.toLowerCase().contains(q) ||
          d.specialty.toLowerCase().contains(q) ||
          d.clinic.toLowerCase().contains(q)).toList();
    });
  }

  // _loadDoctors fetches doctors from the currently selected source
  // If _useExternalJson is true → fetches from GitHub JSON
  // If _useExternalJson is false → fetches from Laravel API (or local JSON if offline)
  Future<void> _loadDoctors() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final doctors = _useExternalJson
          ? await _doctorService.fetchFromExternalJson() // GitHub JSON
          : await _doctorService.getDoctors();           // Laravel API or local JSON
      if (!mounted) return;
      setState(() {
        _doctors  = doctors;
        _filtered = doctors; // Show all doctors initially (no search filter)
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

  // _toggleSource switches between Live API and External JSON
  // This demonstrates the two different data sources for the marker
  void _toggleSource() {
    _useExternalJson = !_useExternalJson; // Flip the source
    _loadDoctors();                        // Reload with the new source
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_useExternalJson
          ? 'Loading from GitHub JSON...'   // Now using GitHub JSON
          : 'Loading from Laravel API...')), // Now using Laravel API
    );
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
        actions: [
          // DATA SOURCE TOGGLE BUTTON — switches between Live API and External JSON
          // The icon and label change to show which source is currently active
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _toggleSource,
              icon: Icon(
                  _useExternalJson
                      ? Icons.cloud_outlined    // Cloud icon for External JSON
                      : Icons.storage_outlined, // Storage icon for Live API
                  size: 16),
              label: Text(
                  _useExternalJson ? 'External JSON' : 'Live API',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
            ),
          ),
        ],
        // SEARCH BAR inside the AppBar below the title
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.onBackground.withOpacity(0.08))),
              child: Row(children: [
                const SizedBox(width: 12),
                Icon(Icons.search,
                    color: cs.onBackground.withOpacity(0.4), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 14, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search doctor, specialty, clinic...',
                      hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14,
                          color: cs.onBackground.withOpacity(0.4)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                // X button to clear the search — only shows when there is text
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onSearch();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.close, size: 18,
                          color: cs.onBackground.withOpacity(0.4)),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),

      // BODY — shows loading, error, empty state or the doctors list
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
      // ERROR STATE — shows retry button if loading failed
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
          : _filtered.isEmpty
      // EMPTY STATE — shows when search returns no results
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48,
                color: cs.onBackground.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text('No doctors found',
                style: TextStyle(fontFamily: 'Poppins',
                    color: cs.onBackground.withOpacity(0.5))),
          ],
        ),
      )
      // DOCTORS LIST — scrollable list of doctor cards
      // Pull down to refresh reloads from current data source
          : RefreshIndicator(
        onRefresh: _loadDoctors,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          itemCount: _filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _DoctorCard(doctor: _filtered[index]),
        ),
      ),
    );
  }
}

// _DoctorCard displays a single doctor in the scrollable list
// Tapping it navigates to DoctorDetailScreen — this is the master/detail pattern
class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      // Navigate to DoctorDetailScreen when card is tapped — master/detail
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
          // Doctor photo — CachedNetworkImage caches it to avoid reloading
          // Shows spinner while loading, person icon if photo fails
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

          // Doctor info — name, specialty badge, clinic, rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15, color: cs.onSurface)),
                const SizedBox(height: 4),
                // Specialty badge with teal background
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
                // Star rating and working hours
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
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
          // Arrow icon showing this card is tappable
          Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.3)),
        ]),
      ),
    );
  }
}