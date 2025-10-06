import '../constants.dart';

class Organizer {
  final String? photo;
  final String email;
  final String countryCode;
  final String phone;
  final String? username;
  final String productionName;
  final int contactWayStatus;

  Organizer({
    this.photo,
    required this.email,
    required this.countryCode,
    required this.phone,
    this.username,
    required this.productionName,
    required this.contactWayStatus,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      photo: json['photo'],
      email: json['email'] ?? '',
      countryCode: json['country_code'] ?? '',
      phone: json['phone'] ?? '',
      username: json['username'],
      productionName: json['production_name'] ?? '',
      contactWayStatus: json['contact_way_status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo': photo,
      'email': email,
      'country_code': countryCode,
      'phone': phone,
      'username': username,
      'production_name': productionName,
      'contact_way_status': contactWayStatus,
    };
  }

  // Helper method to get full phone number
  String get fullPhoneNumber => '$countryCode$phone';

  // Helper method to check if organizer has a photo
  bool get hasPhoto => photo != null && photo!.isNotEmpty;

  // Helper method to get full photo URL
  String? get photoUrl => hasPhoto ? '$kOrganizerImageBaseUrl/$photo' : null;

  // Helper method to get display name
  String get displayName {
    if (productionName.isNotEmpty) return productionName;
    if (username != null && username!.isNotEmpty) return username!;
    return email; // fallback to email if no production name or username
  }
}