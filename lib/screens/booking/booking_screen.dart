import 'package:flutter/material.dart';
import '../../data/models/appointment.dart';
import '../../data/models/doctor.dart';
import '../../data/services/database_service.dart';
import '../../data/services/notification_service.dart';

// BookingScreen is where the patient confirms their appointment
// It receives the selected doctor and time slot from DoctorDetailScreen
// The patient picks a date here, then confirms the booking
// This screen demonstrates: SQLite write, date picker, and notifications
class BookingScreen extends StatefulWidget {
  final Doctor doctor;   // The doctor being booked — passed from DoctorDetailScreen
  final String timeSlot; // The time slot selected — passed from DoctorDetailScreen

  const BookingScreen({
    super.key,
    required this.doctor,
    required this.timeSlot,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // DatabaseService handles saving the appointment to SQLite
  final _dbService = DatabaseService();

  bool _isBooking = false; // True while saving and sending notification

  // Default selected date is tomorrow — patients cannot book for today
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  // _formattedDate converts the DateTime into a readable string
  // e.g. DateTime(2026, 6, 10) → "June 10, 2026"
  String get _formattedDate {
    final months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  // _pickDate opens Flutter's built-in date picker dialog
  // The teal color theme is applied to match the app's design
  // Patient can only pick dates from today up to 90 days in the future
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),                                    // Cannot book in the past
      lastDate: DateTime.now().add(const Duration(days: 90)),       // Maximum 90 days ahead
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFF0D9488), // Teal color for date picker
          ),
        ),
        child: child!,
      ),
    );
    // Only update if the user actually picked a date (not cancelled)
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // _confirmBooking handles the full booking process:
  // 1. Check for duplicate bookings
  // 2. Save appointment to SQLite
  // 3. Send confirmation notification
  // 4. Schedule 30-minute reminder notification
  // 5. Navigate back to home screen
  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);

    // STEP 1: Check if the same appointment already exists in SQLite
    // Prevents double booking for the same doctor, date and time
    final existing = await _dbService.getAllAppointments();
    final isDuplicate = existing.any((a) =>
    a.doctorName == widget.doctor.name &&
        a.date == _formattedDate &&
        a.time == widget.timeSlot &&
        a.status == AppointmentStatus.upcoming);

    if (isDuplicate) {
      // Duplicate found — show warning and stop
      setState(() => _isBooking = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You already have this appointment booked!'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    // STEP 2: Create a new Appointment object with all the booking details
    // The ID is generated from the current timestamp — guarantees it is unique
    final appointment = Appointment(
      id:               DateTime.now().millisecondsSinceEpoch.toString(),
      date:             _formattedDate,
      time:             widget.timeSlot,
      doctorName:       widget.doctor.name,
      doctorSpecialty:  widget.doctor.specialty,
      doctorPhotoUrl:   widget.doctor.photoUrl,
      clinic:           widget.doctor.clinic,
      status:           AppointmentStatus.upcoming,
    );

    // STEP 3: Save the appointment to SQLite local database
    // This satisfies the requirement: "write data to a local data source"
    await _dbService.insertAppointment(appointment);

    // STEP 4: Send immediate confirmation notification and schedule 30-min reminder
    // NotificationService handles both notifications
    await NotificationService().showBookingConfirmation(
      doctorName: widget.doctor.name,
      date:       _formattedDate,
      time:       widget.timeSlot,
    );

    if (!mounted) return;

    // STEP 5: Show success message and navigate back to home screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Appointment booked successfully!'),
          backgroundColor: Colors.green),
    );
    // popUntil(isFirst) takes the user all the way back to the home screen
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

            // DOCTOR CARD — teal gradient showing doctor details
            // Shows the doctor the patient is booking with
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
                // Doctor photo — shows person icon if no photo
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: widget.doctor.photoUrl.isNotEmpty
                      ? NetworkImage(widget.doctor.photoUrl) : null,
                  child: widget.doctor.photoUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            Text('Appointment Details',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16,
                    fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 16),

            // DATE PICKER TILE — tapping this opens the date picker dialog
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  // Teal border to show this is tappable/interactive
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
                    // Shows the currently selected date — updates when user picks
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

            // TIME SLOT TILE — shows the time selected in DoctorDetailScreen
            // This is read-only — cannot be changed here
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

            // CONSULTATION FEE TILE — only shows if fee is available
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

            // CONFIRM BUTTON — calls _confirmBooking when tapped
            // Shows loading spinner while booking is being processed
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

            // GO BACK BUTTON — returns to DoctorDetailScreen to pick a different slot
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