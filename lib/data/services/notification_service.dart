import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../main.dart';

// Studied topic: Mobile device capabilities — Local Notifications
// Sends and schedules appointment reminder notifications
class NotificationService {

  // Initialize timezone data
  static void initTimezone() {
    tz.initializeTimeZones();
  }

  // Parse date string like "June 10, 2026" to DateTime
  DateTime? _parseDate(String date, String time) {
    try {
      const months = {
        'January': 1, 'February': 2, 'March': 3, 'April': 4,
        'May': 5, 'June': 6, 'July': 7, 'August': 8,
        'September': 9, 'October': 10, 'November': 11, 'December': 12
      };

      // Parse date: "June 10, 2026"
      final dateParts = date.replaceAll(',', '').split(' ');
      final month = months[dateParts[0]] ?? 1;
      final day = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Parse time: "09:00 AM" or "02:30 PM"
      final timeParts = time.split(' ');
      final hourMin = timeParts[0].split(':');
      int hour = int.parse(hourMin[0]);
      final minute = int.parse(hourMin[1]);
      final isPM = timeParts[1] == 'PM';

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  // Show immediate booking confirmation notification
  Future<void> showBookingConfirmation({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Booking Confirmations',
      channelDescription: 'Notifications for appointment bookings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        'Your appointment with $doctorName on $date at $time is booked. You will be reminded 30 minutes before your appointment.',
        contentTitle: '✅ Appointment Confirmed!',
        summaryText: 'MediSlot',
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '✅ Appointment Confirmed!',
      'Your appointment with $doctorName on $date at $time is booked. You will be reminded 30 minutes before.',
      NotificationDetails(android: androidDetails),
    );

    // Schedule reminder 30 minutes before appointment
    await _scheduleReminder(
      doctorName: doctorName,
      date: date,
      time: time,
    );
  }

  // Schedule reminder 30 minutes before appointment
  Future<void> _scheduleReminder({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    final appointmentTime = _parseDate(date, time);
    if (appointmentTime == null) return;

    final reminderTime = appointmentTime.subtract(const Duration(minutes: 30));

    // Only schedule if reminder time is in the future
    if (reminderTime.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Appointment Reminders',
      channelDescription: 'Reminders 30 minutes before appointments',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000) + 1,
        '🔔 Appointment in 30 minutes!',
        'Your appointment with $doctorName is at $time. Get ready!',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Scheduled notification error: $e');
    }
  }
}