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

  /// Order in which the category should be displayed.
  final int serialNumber;

  /// Whether this category is featured ('1' for yes, '0' for no).
  final String isFeatured;


  /// Creates a new [Category] instance.
  ///
  /// All parameters are required:
  /// - [id]: Unique identifier for the category
  /// - [name]: Localized name of the category
  /// - [languageId]: ID of the language this category's name is in
  /// - [image]: URL or path to the category's image
  /// - [slug]: URL-friendly version of the category name
  /// - [serialNumber]: Display order of the category
  /// - [isFeatured]: Whether this category is featured ('1' for yes, '0' for no)
  Category({
    required this.id,
    required this.name,
    required this.languageId,
    required this.image,
    required this.slug,
    required this.serialNumber,
    required this.isFeatured,
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
      serialNumber: json['serial_number'] as int,
      isFeatured: json['is_featured'] as String,
    );
  }

  /// Converts this [Category] instance to a JSON map.
  ///
  /// Returns a Map that can be serialized to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language_id': languageId,
      'image': image,
      'slug': slug,
      'serial_number': serialNumber,
      'is_featured': isFeatured,
    };
  }
}
