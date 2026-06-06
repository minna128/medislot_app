import 'package:flutter/material.dart';
import '../../data/models/appointment.dart';
import '../../data/models/doctor.dart';
import '../../data/services/database_service.dart';
import '../../data/services/notification_service.dart';

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
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  String get _formattedDate {
    final months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFF0D9488),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);

    // Check for duplicate booking
    final existing = await _dbService.getAllAppointments();
    final isDuplicate = existing.any((a) =>
    a.doctorName == widget.doctor.name &&
        a.date == _formattedDate &&
        a.time == widget.timeSlot &&
        a.status == AppointmentStatus.upcoming);

    if (isDuplicate) {
      setState(() => _isBooking = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You already have this appointment booked!'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _formattedDate,
      time: widget.timeSlot,
      doctorName: widget.doctor.name,
      doctorSpecialty: widget.doctor.specialty,
      doctorPhotoUrl: widget.doctor.photoUrl,
      clinic: widget.doctor.clinic,
      status: AppointmentStatus.upcoming,
    );

    await _dbService.insertAppointment(appointment);

// Send booking confirmation notification
    await NotificationService().showBookingConfirmation(
      doctorName: widget.doctor.name,
      date: _formattedDate,
      time: widget.timeSlot,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment booked successfully!'),
          backgroundColor: Colors.green),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        title: const Text('Confirm Booking',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: cs.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: widget.doctor.photoUrl.isNotEmpty
                      ? NetworkImage(widget.doctor.photoUrl) : null,
                  child: widget.doctor.photoUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.doctor.name,
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold, fontSize: 16,
                          color: Colors.white)),
                  Text(widget.doctor.specialty,
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontSize: 13, color: Colors.white70)),
                  Text(widget.doctor.clinic,
                      style: const TextStyle(fontFamily: 'Poppins',
                          fontSize: 12, color: Colors.white60)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),

            Text('Appointment Details',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
                    fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: Color(0xFF0D9488), size: 20),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Tap to select date',
                        style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 11, color: cs.onSurface.withOpacity(0.5))),
                    Text(_formattedDate,
                        style: TextStyle(fontFamily: 'Poppins',
                            fontSize: 15, fontWeight: FontWeight.w600,
                            color: cs.onSurface)),
                  ]),
                  const Spacer(),
                  const Icon(Icons.edit_calendar_outlined,
                      color: Color(0xFF0D9488), size: 18),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.onSurface.withOpacity(0.08)),
              ),
              child: Row(children: [
                const Icon(Icons.access_time_outlined,
                    color: Color(0xFF0D9488), size: 20),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Time Slot', style: TextStyle(fontFamily: 'Poppins',
                      fontSize: 11, color: cs.onSurface.withOpacity(0.5))),
                  Text(widget.timeSlot, style: TextStyle(fontFamily: 'Poppins',
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
                ]),
              ]),
            ),

            if (widget.doctor.consultationFee.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                ),
                child: Row(children: [
                  const Icon(Icons.payments_outlined,
                      color: Color(0xFF0D9488), size: 20),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Consultation Fee', style: TextStyle(fontFamily: 'Poppins',
                        fontSize: 11, color: cs.onSurface.withOpacity(0.5))),
                    Text(widget.doctor.consultationFee,
                        style: const TextStyle(fontFamily: 'Poppins',
                            fontSize: 15, fontWeight: FontWeight.w600,
                            color: Color(0xFF0D9488))),
                  ]),
                ]),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontFamily: 'Poppins',
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: _isBooking
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Confirm Booking — $_formattedDate'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D9488),
                  side: const BorderSide(color: Color(0xFF0D9488)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Go Back',
                    style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
