// Studied topic: Dart
// Appointment model with status enum — saved to and read from SQLite
class Appointment {
  final String id;
  final String date;
  final String time;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorPhotoUrl;
  final String clinic;
  final AppointmentStatus status;

  const Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorPhotoUrl,
    required this.clinic,
    this.status = AppointmentStatus.upcoming,
  });

  // Convert to Map for SQLite INSERT
  Map<String, dynamic> toMap() => {
    'id': id, 'date': date, 'time': time,
    'doctorName': doctorName, 'doctorSpecialty': doctorSpecialty,
    'doctorPhotoUrl': doctorPhotoUrl, 'clinic': clinic,
    'status': status.name,
  };

  // Parse from SQLite row
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id:               map['id'],
      date:             map['date'],
      time:             map['time'],
      doctorName:       map['doctorName'],
      doctorSpecialty:  map['doctorSpecialty'],
      doctorPhotoUrl:   map['doctorPhotoUrl'] ?? '',
      clinic:           map['clinic'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.upcoming,
      ),
    );
  }

  // Immutable update — creates a new object with changed fields
  Appointment copyWith({AppointmentStatus? status}) => Appointment(
    id: id, date: date, time: time, doctorName: doctorName,
    doctorSpecialty: doctorSpecialty, doctorPhotoUrl: doctorPhotoUrl,
    clinic: clinic, status: status ?? this.status,
  );
}

enum AppointmentStatus {
  upcoming,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case AppointmentStatus.upcoming:  return 'Upcoming';
      case AppointmentStatus.completed: return 'Completed';
      case AppointmentStatus.cancelled: return 'Cancelled';
    }
  }
}
