class Category {
  final int id;
  final String name;
  final int languageId;
  final String image;
  final String slug;
  final int status;
  final int serialNumber;
  final String isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.languageId,
    required this.image,
    required this.slug,
    required this.status,
    required this.serialNumber,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      languageId: json['language_id'] as int,
      image: json['image'] as String,
      slug: json['slug'] as String,
      status: json['status'] as int,
      serialNumber: json['serial_number'] as int,
      isFeatured: json['is_featured'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
