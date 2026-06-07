// This is the Doctor model — it represents a single doctor in the app
// I use this model to store doctor data whether it comes from the API,
// external JSON file, or local JSON file
class Doctor {
  // These are all the fields that make up one doctor
  final String id;              // Unique ID from the database
  final String name;            // Doctor's full name e.g. "Dr. Sarah Lee"
  final String specialty;       // Medical specialty e.g. "Cardiologist"
  final String clinic;          // Clinic name e.g. "Heart Care Clinic"
  final String experience;      // Working hours e.g. "Mon-Fri 9am-5pm"
  final String consultationFee; // Fee e.g. "LKR 3,500"
  final String photoUrl;        // URL of doctor's photo
  final String bio;             // Short description about the doctor
  final double rating;          // Star rating out of 5

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.clinic,
    required this.experience,
    required this.consultationFee,
    required this.photoUrl,
    required this.bio,
    required this.rating,
  });

  // fromJson parses a Doctor from the LOCAL JSON file (assets/data/doctors.json)
  // and the EXTERNAL JSON file (GitHub)
  // The field names in these JSON files match exactly — id, name, specialty etc.
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id:              json['id'].toString(),
      name:            json['name'] ?? '',
      specialty:       json['specialty'] ?? '',
      clinic:          json['clinic'] ?? '',
      experience:      json['experience'] ?? '',
      consultationFee: json['consultationFee'] ?? '',
      photoUrl:        json['photoUrl'] ?? '',
      bio:             json['bio'] ?? '',
      // rating comes as a number so I convert it to double
      // if missing, default to 4.5
      rating:          (json['rating'] as num?)?.toDouble() ?? 4.5,
    );
  }

  // fromApiJson parses a Doctor from the LARAVEL API response
  // The API returns different field names compared to the JSON files
  // For example: "specialization" instead of "specialty"
  //              "clinic_location" instead of "clinic"
  //              "availability" instead of "experience"
  factory Doctor.fromApiJson(Map<String, dynamic> json) {
    // Get the doctor's first name in lowercase to build the photo URL
    // e.g. "Sarah Lee" → "sarah"
    final firstName = (json['name'] ?? '').toString().toLowerCase().split(' ').first;

    // Only these doctors have photos on the AWS server
    // If the doctor's first name is not in this list, we use an empty URL
    // and the app will show a person icon placeholder instead
    final validPhotos = ['ahmed', 'daniel', 'emily', 'emma', 'james', 'michael', 'olivia', 'sarah'];

    // Build the photo URL using the doctor's first name
    // e.g. "https://medi-slot.ddns.net/images/doctors/sarah.jpg"
    final photoUrl = validPhotos.contains(firstName)
        ? 'https://medi-slot.ddns.net/images/doctors/$firstName.jpg'
        : '';

    return Doctor(
      id:              json['id'].toString(),
      name:            'Dr. ${json['name'] ?? ''}', // Add "Dr." prefix to the name
      specialty:       json['specialization'] ?? '', // API uses "specialization" not "specialty"
      clinic:          json['clinic_location'] ?? '', // API uses "clinic_location" not "clinic"
      experience:      json['availability'] ?? '',    // API uses "availability" not "experience"
      consultationFee: '',                            // API does not return fee so left empty
      photoUrl:        photoUrl,
      bio:             json['availability'] ?? '',    // Use availability as bio description
      rating:          4.5,                           // API does not return rating so default to 4.5
    );
  }

  // toJson converts the Doctor object to a Map
  // I use this when I need to store or send doctor data
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'specialty': specialty,
    'clinic': clinic,
    'experience': experience,
    'consultationFee': consultationFee,
    'photoUrl': photoUrl,
    'bio': bio,
    'rating': rating,
  };
}