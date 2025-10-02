import 'package:day_night/controllers/shared/primary_dropdown_field.dart';

class ParticipantInfo {
  final String fullName;
  final String? idNumber;
  final String? dateOfBirth;
  final Gender? gender;

  const ParticipantInfo({
    required this.fullName,
    this.idNumber,
    this.dateOfBirth,
    this.gender,
  });
}