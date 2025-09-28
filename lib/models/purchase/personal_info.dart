class PersonalInfo {
  final String fullName;
  final String email;
  final String phone;
  final String? idNumber; // Optional, might be required for some events

  const PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    this.idNumber,
  });
}