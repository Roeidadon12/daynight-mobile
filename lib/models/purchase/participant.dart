import 'package:day_night/models/gender.dart' as gender_model;

class Participant {
  final String fullName;
  final String? idNumber;
  final String? dateOfBirth;
  final gender_model.Gender? gender;

  const Participant({
    required this.fullName,
    this.idNumber,
    this.dateOfBirth,
    this.gender,
  });
}