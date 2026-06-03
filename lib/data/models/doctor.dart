// Studied topic: Dart / reading data from JSON
// This model parses a doctor object from JSON
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String clinic;
  final String experience;
  final String consultationFee;
  final String photoUrl;
  final String bio;
  final double rating;

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

  // Parse from local JSON file
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
      rating:          (json['rating'] as num?)?.toDouble() ?? 4.5,
    );
  }

  // Parse from Laravel API response (different field names)
  factory Doctor.fromApiJson(Map<String, dynamic> json) {
    return Doctor(
      id:              json['id'].toString(),
      name:            json['name'] ?? '',
      specialty:       json['specialization'] ?? '',
      clinic:          json['clinic_location'] ?? '',
      experience:      '',
      consultationFee: '',
      photoUrl:        '',
      bio:             json['availability'] ?? '',
      rating:          4.5,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'specialty': specialty,
    'clinic': clinic, 'experience': experience,
    'consultationFee': consultationFee, 'photoUrl': photoUrl,
    'bio': bio, 'rating': rating,
  };
}