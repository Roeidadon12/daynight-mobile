class User {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String sex;
  final DateTime dob;
  final String idNumber;
  final String? thumbnail;
  final String? address;

  User({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.sex,
    required this.dob,
    required this.idNumber,
    this.thumbnail,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      sex: json['sex'] as String,
      dob: DateTime.parse(json['dob'] as String),
      idNumber: json['idNumber'] as String,
      thumbnail: json['thumbnail'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'sex': sex,
        'dob': dob.toIso8601String(),
        'idNumber': idNumber,
        if (thumbnail != null) 'thumbnail': thumbnail,
        if (address != null) 'address': address,
      };
}
