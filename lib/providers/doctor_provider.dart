import 'package:flutter/material.dart';
import '../data/models/doctor.dart';
import '../data/services/doctor_service.dart';

// Studied topic: State Management with Provider
// DoctorProvider manages the doctors list state across the app
// Both HomeScreen and DoctorsScreen share the same data without reloading
class DoctorProvider extends ChangeNotifier {
  final DoctorService _doctorService = DoctorService();

  List<Doctor> _doctors = [];
  bool _isLoading = false;
  String _error = '';
  bool _loaded = false;

  // Getters
  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Top 4 doctors by rating — used in HomeScreen
  List<Doctor> get topDoctors {
    final sorted = [..._doctors]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(4).toList();
  }

  // Load doctors — only fetches once unless forced
  Future<void> loadDoctors({bool force = false}) async {
    if (_loaded && !force) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _doctors = await _doctorService.getDoctors();
      _loaded = true;
    } catch (e) {
      _error = 'Failed to load doctors';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Search doctors by name, specialty or clinic
  List<Doctor> search(String query) {
    if (query.isEmpty) return _doctors;
    final q = query.toLowerCase();
    return _doctors.where((d) =>
    d.name.toLowerCase().contains(q) ||
        d.specialty.toLowerCase().contains(q) ||
        d.clinic.toLowerCase().contains(q)).toList();
  }
}