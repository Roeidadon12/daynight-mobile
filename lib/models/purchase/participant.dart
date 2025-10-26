import 'package:day_night/models/gender.dart' as gender_model;

class Participant {
  final String fullName;
  final String ticketId;
  final String? idNumber;
  final String? dateOfBirth;
  final String? phoneNumber;
  final gender_model.Gender? gender;
  final String? facebookId;
  final String? instagramId;

  const Participant({
    required this.fullName,
    required this.ticketId,
    this.idNumber,
    this.dateOfBirth,
    this.phoneNumber,
    this.gender,
    this.facebookId,
    this.instagramId,
  });
}
