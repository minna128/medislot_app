import 'package:flutter/material.dart';
import '../../data/models/appointment.dart';
import '../../data/models/doctor.dart';
import '../../data/services/database_service.dart';

// Studied topics: StatefulWidget, saving data (writes to SQLite)
class BookingScreen extends StatefulWidget {
  final Doctor doctor;
  final String timeSlot;

  const BookingScreen({
    super.key,
    required this.doctor,
    required this.timeSlot,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _dbService = DatabaseService();
  bool _isBooking = false;

  // Simple fixed date for demo — can be replaced with DatePicker later
  final String _selectedDate = 'June 10, 2026';

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);

    // Create a new Appointment object
    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      time: widget.timeSlot,
      doctorName: widget.doctor.name,
      doctorSpecialty: widget.doctor.specialty,
      doctorPhotoUrl: widget.doctor.photoUrl,
      clinic: widget.doctor.clinic,
      status: AppointmentStatus.upcoming,
    );

    // Studied topic: saving data — write to SQLite
    await _dbService.insertAppointment(appointment);

    if (!mounted) return;

    // Go back to home tab (index 0)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment booked successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Pop back to doctors screen then navigate home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _SummaryRow(
                      icon: Icons.person_outline,
                      label: 'Doctor',
                      value: widget.doctor.name,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      icon: Icons.medical_services_outlined,
                      label: 'Specialty',
                      value: widget.doctor.specialty,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      icon: Icons.location_on_outlined,
                      label: 'Clinic',
                      value: widget.doctor.clinic,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: _selectedDate,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      icon: Icons.access_time_outlined,
                      label: 'Time',
                      value: widget.timeSlot,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      icon: Icons.payments_outlined,
                      label: 'Fee',
                      value: widget.doctor.consultationFee,
                      valueColor: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isBooking ? null : _confirmBooking,
              child: _isBooking
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirm & Book'),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
