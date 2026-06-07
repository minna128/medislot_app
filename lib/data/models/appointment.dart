// This is the Appointment model — it represents a single appointment in the app
// It holds all the details of a booking made by the patient
// This model is saved to and read from the SQLite local database on the device
class Appointment {
  // These are all the fields that make up one appointment
  final String id;             // Unique ID — generated from timestamp when booking is made
  final String date;           // Date of appointment e.g. "June 10, 2026"
  final String time;           // Time slot e.g. "09:00 AM"
  final String doctorName;     // Name of the doctor being booked
  final String doctorSpecialty;// Doctor's specialty e.g. "Cardiologist"
  final String doctorPhotoUrl; // URL of the doctor's photo from AWS server
  final String clinic;         // Clinic name e.g. "Heart Care Clinic"
  final AppointmentStatus status; // Current status — upcoming, completed or cancelled

  const Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorPhotoUrl,
    required this.clinic,
    // Default status is upcoming when a new appointment is created
    this.status = AppointmentStatus.upcoming,
  });

  // This method converts the Appointment object into a Map
  // SQLite cannot store objects directly — it needs key-value pairs
  // So I convert each field into a map entry before saving to the database
  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'time': time,
    'doctorName': doctorName,
    'doctorSpecialty': doctorSpecialty,
    'doctorPhotoUrl': doctorPhotoUrl,
    'clinic': clinic,
    'status': status.name, // Converts enum to string e.g. "upcoming"
  };

  // This is a factory constructor — it creates an Appointment object from a SQLite row
  // When I read data from SQLite, it comes back as a Map
  // This method converts that Map back into an Appointment object
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id:               map['id'],
      date:             map['date'],
      time:             map['time'],
      doctorName:       map['doctorName'],
      doctorSpecialty:  map['doctorSpecialty'],
      doctorPhotoUrl:   map['doctorPhotoUrl'] ?? '', // Use empty string if no photo
      clinic:           map['clinic'],
      // Convert the stored string back to the enum value
      // If the status string doesn't match, default to upcoming
      status: AppointmentStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.upcoming,
      ),
    );
  }

  // copyWith creates a new Appointment with one field changed
  // I use this when cancelling an appointment — everything stays the same
  // except the status changes to cancelled
  // Flutter models are immutable so I cannot change a field directly
  Appointment copyWith({AppointmentStatus? status}) => Appointment(
    id: id,
    date: date,
    time: time,
    doctorName: doctorName,
    doctorSpecialty: doctorSpecialty,
    doctorPhotoUrl: doctorPhotoUrl,
    clinic: clinic,
    status: status ?? this.status, // Use new status if provided, otherwise keep existing
  );
}

// AppointmentStatus is an enum — it represents the 3 possible states of an appointment
// Using an enum instead of plain strings prevents typos and makes the code cleaner
enum AppointmentStatus {
  upcoming,   // Appointment is booked and has not happened yet
  completed,  // Appointment has been attended
  cancelled;  // Appointment was cancelled by the patient

  // label returns a readable string version of the status
  // Used to display the status badge on the appointments screen
  String get label {
    switch (this) {
      case AppointmentStatus.upcoming:  return 'Upcoming';
      case AppointmentStatus.completed: return 'Completed';
      case AppointmentStatus.cancelled: return 'Cancelled';
    }
  }
}