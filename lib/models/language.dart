class Language {
  final int id;
  final String name;
  final String code;
  final int direction;
  final int isDefault;
  final Map<String, String>? keywords;

  Language({
    required this.id,
    required this.name,
    required this.code,
    required this.direction,
    required this.isDefault,
    required this.keywords,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      direction: json['direction'] as int,
      isDefault: json['is_default'] as int,
      keywords: (json['keywords'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as String),
      ),
    );
  }
}
