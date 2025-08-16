class Language {
  final int id;
  final String name;
  final String code;
  final int direction;
  final int isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Language({
    required this.id,
    required this.name,
    required this.code,
    required this.direction,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      direction: json['direction'] as int,
      isDefault: json['is_default'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
