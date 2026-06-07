import 'package:flutter/material.dart';
import '../data/models/doctor.dart';
import '../data/services/doctor_service.dart';

// DoctorProvider is the second Provider in the app (AuthProvider is the first)
// It manages the doctors list and shares it between HomeScreen and DoctorsScreen
// Without Provider, both screens would separately call the API and load doctors twice
// With Provider, doctors are loaded ONCE and both screens read from the same list
// This is a key benefit of state management — avoiding duplicate API calls
class DoctorProvider extends ChangeNotifier {
  // DoctorService handles all the data fetching (API, external JSON, local JSON)
  final DoctorService _doctorService = DoctorService();

  // Private variables storing the current state
  List<Doctor> _doctors = []; // The full list of doctors
  bool _isLoading = false;    // True while doctors are being loaded
  String _error = '';          // Stores error message if loading fails
  bool _loaded = false;        // Tracks if doctors have been loaded already

  // Getters — screens read these values using context.watch<DoctorProvider>()
  List<Doctor> get doctors   => _doctors;
  bool get isLoading         => _isLoading;
  String get error           => _error;

  // topDoctors returns the top 4 doctors sorted by rating
  // Used in HomeScreen to show the "Top Doctors" section
  // The spread operator [..._doctors] creates a copy so the original list is not changed
  List<Doctor> get topDoctors {
    final sorted = [..._doctors]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(4).toList(); // Only return the top 4
  }

  // loadDoctors fetches the doctors list from DoctorService
  // The _loaded flag prevents unnecessary API calls when switching between screens
  // For example: user goes Home → Doctors → Home — doctors only load ONCE
  // force:true is used to force a reload when the user pulls to refresh
  Future<void> loadDoctors({bool force = false}) async {
    if (_loaded && !force) return; // Skip if already loaded and not forced

    _isLoading = true;
    _error = '';
    notifyListeners(); // Tell HomeScreen and DoctorsScreen to show loading indicator

    try {
      // DoctorService automatically picks API, external JSON, or local JSON
      // depending on internet connectivity
      _doctors = await _doctorService.getDoctors();
      _loaded = true; // Mark as loaded so we don't reload unnecessarily
    } catch (e) {
      // If all data sources fail, store the error message
      _error = 'Failed to load doctors';
    }

    _isLoading = false;
    notifyListeners(); // Tell all screens that doctors are ready — rebuild!
  }

  // search filters the doctors list based on the search query
  // It checks if the query matches the doctor's name, specialty, or clinic
  // Used in DoctorsScreen search bar — updates results as the user types
  List<Doctor> search(String query) {
    if (query.isEmpty) return _doctors; // Return all doctors if search is empty
    final q = query.toLowerCase();
    return _doctors.where((d) =>
    d.name.toLowerCase().contains(q) ||
        d.specialty.toLowerCase().contains(q) ||
        d.clinic.toLowerCase().contains(q)).toList();
  }
}