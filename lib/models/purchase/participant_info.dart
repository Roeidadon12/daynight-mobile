import 'package:day_night/models/gender.dart' as gender_model;

class ParticipantInfo {
  final String fullName;
  final String? idNumber;
  final String? dateOfBirth;
  final gender_model.Gender? gender;

  const ParticipantInfo({
    required this.fullName,
    this.idNumber,
    this.dateOfBirth,
    this.gender,
  });
}