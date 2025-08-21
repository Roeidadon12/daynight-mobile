/// Represents an event category in the DayNight application.
///
/// Categories are used to organize and filter events. Each category has its own
/// localized name, image, and various attributes that determine how it's displayed
/// and used in the application.
class Category {
  /// Unique identifier for the category.
  final int id;

  /// Localized name of the category.
  final String name;

  /// ID of the language this category's name is in.
  final int languageId;

  /// URL or path to the category's image.
  final String image;

  /// URL-friendly version of the category name.
  final String slug;

  /// Status of the category (e.g., 1 for active, 0 for inactive).
  final int status;

  /// Order in which the category should be displayed.
  final int serialNumber;

  /// Whether this category is featured ('1' for yes, '0' for no).
  final String isFeatured;

  /// When the category was created.
  final DateTime createdAt;

  /// When the category was last updated.
  final DateTime updatedAt;

  /// Creates a new [Category] instance.
  ///
  /// All parameters are required:
  /// - [id]: Unique identifier for the category
  /// - [name]: Localized name of the category
  /// - [languageId]: ID of the language this category's name is in
  /// - [image]: URL or path to the category's image
  /// - [slug]: URL-friendly version of the category name
  /// - [status]: Status of the category (1 for active, 0 for inactive)
  /// - [serialNumber]: Display order of the category
  /// - [isFeatured]: Whether this category is featured ('1' for yes, '0' for no)
  /// - [createdAt]: Creation timestamp
  /// - [updatedAt]: Last update timestamp
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

  /// Creates a [Category] instance from a JSON map.
  ///
  /// Expects a Map containing all required fields with their appropriate types.
  /// Throws a type error if required fields are missing or of wrong type.
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
