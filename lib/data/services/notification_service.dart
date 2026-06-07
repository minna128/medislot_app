import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../main.dart';

// NotificationService handles all notifications in the app
// It uses the flutter_local_notifications package to show and schedule notifications
// This is one of the 3 mobile device capabilities demonstrated in the app
// Two types of notifications are used:
// 1. Immediate confirmation — fires right when the user confirms a booking
// 2. Scheduled reminder — fires 30 minutes before the appointment time
class NotificationService {

  // _parseDate converts the appointment date and time strings into a DateTime object
  // This is needed so we can calculate when to schedule the reminder
  // For example: date = "June 10, 2026" and time = "09:00 AM" → DateTime(2026, 6, 10, 9, 0)
  DateTime? _parseDate(String date, String time) {
    try {
      // Map of month names to their numbers
      const months = {
        'January': 1, 'February': 2, 'March': 3, 'April': 4,
        'May': 5, 'June': 6, 'July': 7, 'August': 8,
        'September': 9, 'October': 10, 'November': 11, 'December': 12
      };

      // Parse date string: "June 10, 2026"
      // Remove the comma then split by space → ["June", "10", "2026"]
      final dateParts = date.replaceAll(',', '').split(' ');
      final month = months[dateParts[0]] ?? 1;
      final day   = int.parse(dateParts[1]);
      final year  = int.parse(dateParts[2]);

      // Parse time string: "09:00 AM" or "02:30 PM"
      // Split by space → ["09:00", "AM"]
      final timeParts = time.split(' ');
      final hourMin   = timeParts[0].split(':');
      int hour        = int.parse(hourMin[0]);
      final minute    = int.parse(hourMin[1]);
      final isPM      = timeParts[1] == 'PM';

      // Convert 12-hour format to 24-hour format
      // e.g. 2:00 PM → 14:00, 12:00 AM → 0:00
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      // If parsing fails for any reason, return null
      // The calling method will handle the null case
      return null;
    }
  }

  // showBookingConfirmation shows an immediate notification when a booking is confirmed
  // It also calls _scheduleReminder to set up the 30-minute reminder
  // Called from BookingScreen after the appointment is saved to SQLite
  Future<void> showBookingConfirmation({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    // BigTextStyleInformation shows the full message when the notification is expanded
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'booking_channel',        // Unique channel ID for booking notifications
      'Booking Confirmations',  // Channel name shown in phone settings
      channelDescription: 'Notifications for appointment bookings',
      importance: Importance.high, // Makes the notification appear as a popup
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Use the app icon for the notification
      styleInformation: BigTextStyleInformation(
        // Full message shown when notification is expanded
        'Your appointment with $doctorName on $date at $time is booked. You will be reminded 30 minutes before your appointment.',
        contentTitle: '✅ Appointment Confirmed!',
        summaryText: 'MediSlot',
      ),
    );

    // Show the notification immediately
    await flutterLocalNotificationsPlugin.show(
      // Use remainder to keep the ID within integer range
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '✅ Appointment Confirmed!',
      'Your appointment with $doctorName on $date at $time is booked. You will be reminded 30 minutes before.',
      NotificationDetails(android: androidDetails),
    );

    // Schedule the 30-minute reminder notification
    await _scheduleReminder(
      doctorName: doctorName,
      date: date,
      time: time,
    );
  }

  // _scheduleReminder schedules a notification to fire 30 minutes before the appointment
  // It uses the timezone package to handle local time correctly
  // SCHEDULE_EXACT_ALARM permission is required in AndroidManifest.xml for this to work
  Future<void> _scheduleReminder({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    // Convert the date and time strings to a DateTime object
    final appointmentTime = _parseDate(date, time);
    if (appointmentTime == null) return; // Stop if parsing failed

    // Calculate the reminder time — 30 minutes before the appointment
    final reminderTime = appointmentTime.subtract(const Duration(minutes: 30));

    // Only schedule if the reminder time is still in the future
    // If the appointment is less than 30 minutes away, skip the reminder
    if (reminderTime.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',       // Separate channel for reminder notifications
      'Appointment Reminders',
      channelDescription: 'Reminders 30 minutes before appointments',
      importance: Importance.max, // Max importance so it appears even in DND mode
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    try {
      // zonedSchedule fires the notification at a specific future time
      // tz.TZDateTime.from converts the DateTime to the device's local timezone
      await flutterLocalNotificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000) + 1,
        '🔔 Appointment in 30 minutes!',
        'Your appointment with $doctorName is at $time. Get ready!',
        tz.TZDateTime.from(reminderTime, tz.local), // Schedule in local timezone
        const NotificationDetails(android: androidDetails),
        // exactAllowWhileIdle fires even when the phone is in battery saver mode
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // If scheduling fails, print the error but don't crash the app
      print('Scheduled notification error: $e');
    }
  }
}