import 'package:day_night/models/gender.dart' as gender_model;

/// Model to encapsulate all participant information including validation state
class ParticipantData {
  // Basic information
  String ticketId;
  String firstName;
  String lastName;
  String phoneNumber;
  String idNumber;
  String dateOfBirth;
  gender_model.Gender? gender;
  String? idCardImagePath;
  String? facebookId;
  String? instagramId;

  // Validation state
  bool firstNameError;
  bool lastNameError;
  bool phoneNumberError;
  bool idNumberError;
  bool dateOfBirthError;
  bool genderError;
  bool idCardImageError;
  bool facebookIdError;
  bool instagramIdError;

  ParticipantData({
    required this.ticketId,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.idNumber = '',
    this.dateOfBirth = '',
    this.gender,
    this.idCardImagePath,
    this.facebookId,
    this.instagramId,
    this.firstNameError = false,
    this.lastNameError = false,
    this.phoneNumberError = false,
    this.idNumberError = false,
    this.dateOfBirthError = false,
    this.genderError = false,
    this.idCardImageError = false,
    this.facebookIdError = false,
    this.instagramIdError = false,
  });

  /// Resets all error states
  void clearErrors() {
    firstNameError = false;
    lastNameError = false;
    phoneNumberError = false;
    idNumberError = false;
    dateOfBirthError = false;
    genderError = false;
    idCardImageError = false;
    facebookIdError = false;
    instagramIdError = false;
  }

  /// Checks if the participant data is valid (has no errors)
  bool get isValid {
    return !firstNameError &&
           !lastNameError &&
           !phoneNumberError &&
           !idNumberError &&
           !dateOfBirthError &&
           !genderError &&
           !idCardImageError &&
           !facebookIdError &&
           !instagramIdError;
  }

  /// Checks if the participant data is complete (has required information)
  bool get hasBasicInfo {
    return firstName.isNotEmpty && lastName.isNotEmpty;
  }

  /// Gets the full name for display purposes
  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) return '';
    return '$firstName $lastName'.trim();
  }

  /// Creates a copy of this participant data
  ParticipantData copy() {
    return ParticipantData(
      ticketId: ticketId,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      idNumber: idNumber,
      dateOfBirth: dateOfBirth,
      gender: gender,
      facebookId: facebookId,
      instagramId: instagramId,
      idCardImagePath: idCardImagePath,
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      phoneNumberError: phoneNumberError,
      idNumberError: idNumberError,
      dateOfBirthError: dateOfBirthError,
      genderError: genderError,
      idCardImageError: idCardImageError,
      facebookIdError: facebookIdError,
      instagramIdError: instagramIdError,
    );
  }

  @override
  String toString() {
    return 'ParticipantData(ticketId: $ticketId, fullName: $fullName, isValid: $isValid)';
  }
}