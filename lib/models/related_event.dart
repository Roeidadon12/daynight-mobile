class RelatedEvent {
  final int id;
  final String thumbnail;
  final String title;
  final String description;
  final String? city;
  final String country;

  const RelatedEvent({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.description,
    this.city,
    required this.country,
  });

  factory RelatedEvent.fromJson(Map<String, dynamic> json) {
    return RelatedEvent(
      id: json['id'] as int,
      thumbnail: json['thumbnail'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      city: json['city'] as String?,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thumbnail': thumbnail,
      'title': title,
      'description': description,
      'city': city,
      'country': country,
    };
  }

  @override
  String toString() {
    return 'RelatedEvent(id: $id, title: "$title", city: $city, country: "$country")';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelatedEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}        