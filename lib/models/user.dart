/// Represents a user in the DayNight application.
///
/// This class contains all personal information about a user, including
/// required fields for event registration and optional profile information.
class User {
  /// The user's full name.
  final String fullName;

  /// The user's phone number.
  /// Should be in a valid phone number format.
  final String phoneNumber;

  /// The user's email address.
  /// Used for account identification and communications.
  final String email;

  /// The user's sex/gender.
  /// Used for demographic information and event restrictions.
  final String sex;

  /// The user's date of birth.
  /// Used for age verification and age-restricted events.
  final DateTime? dob;

  /// The user's ID number (e.g., national ID, passport).
  /// Used for identity verification at events.
  final String? idNumber;

  /// URL or path to the user's profile picture.
  /// Optional - can be null if no picture is set.
  final String? thumbnail;

  /// The user's physical address.
  /// Optional - can be null if not provided.
  final String? address;

  /// Creates a new [User] instance.
  ///
  /// Required parameters:
  /// - [fullName]: The user's full name
  /// - [phoneNumber]: The user's phone number in valid format
  /// - [email]: The user's email address
  /// - [sex]: The user's sex/gender
  /// - [dob]: The user's date of birth
  ///
  /// Optional parameters:
  /// - [idNumber]: The user's ID number
  /// - [thumbnail]: URL/path to profile picture
  /// - [address]: User's physical address
  User({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.sex,
    this.dob,
    this.idNumber,
    this.thumbnail,
    this.address,
  });

  /// Creates a [User] instance from a JSON map.
  ///
  /// Expects a Map containing all required fields with their appropriate types.
  /// Optional fields (thumbnail, address) may be null.
  ///
  /// Throws:
  /// - FormatException if the date string for [dob] is invalid
  /// - TypeError if required fields are missing or of wrong type
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      sex: json['sex'] as String,
      dob: json['dob'] != null ? DateTime.parse(json['dob'] as String) : null,
      idNumber: json['idNumber'] as String?,
      thumbnail: json['thumbnail'] as String?,
      address: json['address'] as String?,
    );
  }

  /// Converts the [User] instance to a JSON map.
  ///
  /// Optional fields are only included if they are non-null.
  /// The date of birth is converted to ISO 8601 format.
  Map<String, dynamic> toJson() {
    final result = {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'sex': sex,
    };

    if (dob != null) result['dob'] = dob!.toIso8601String();
    if (idNumber != null) result['idNumber'] = idNumber!;
    if (thumbnail != null) result['thumbnail'] = thumbnail!;
    if (address != null) result['address'] = address!;

    return result;
  }
}
