
class EventsResponse {
  final String status;
  final Events events;
  // final List<Category> categories;
  final double maxPrice;
  final double minPrice;

  EventsResponse({
    required this.status,
    required this.events,
    // required this.categories,
    required this.maxPrice,
    required this.minPrice,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      status: json['status'],
      events: Events.fromJson(json['events']),
      /* categories: (json['categories'] as List)
          .map((category) => Category.fromJson(category))
          .toList(), */
      maxPrice: (json['max_price'] as num).toDouble(),
      minPrice: (json['min_price'] as num).toDouble(),
    );
  }
}

class Events {
  final int currentPage;
  final List<Event> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  Events({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Events.fromJson(Map<String, dynamic> json) {
    return Events(
      currentPage: json['current_page'],
      data: (json['data'] as List).map((event) => Event.fromJson(event)).toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List)
          .map((link) => PaginationLink.fromJson(link))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class Event {
  final int id;
  final String thumbnail;
  final String title;
  final String description;
  final String startDate;
  final String startTime;
  final String duration;
  final String endDate;
  final String endTime;
  final String endDateTime;
  final String? city;
  final String country;
  final String address;
  final String? zipCode;
  final String categoryName;
  final int categoryId;
  final int? organizerId;
  final String organizerName;
  final String price;

  Event({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.description,
    required this.startDate,
    required this.startTime,
    required this.duration,
    required this.endDate,
    required this.endTime,
    required this.endDateTime,
    this.city,
    required this.country,
    required this.address,
    this.zipCode,
    required this.categoryName,
    required this.categoryId,
    this.organizerId,
    required this.organizerName,
    required this.price,
  });

  /// Returns a formatted string of the start date
  String get formattedStartDate {
    final date = DateTime.parse(startDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Returns a short format of the start date (e.g., "12 Sep")
  String get startShortDate {
    final date = DateTime.parse(startDate);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  /// Returns the complete location string combining city (if available) and country
  String get location {
    if (city != null && city!.isNotEmpty) {
      return '$city, $country';
    }
    return country;
  }

  /// Returns a combination of location and event date/time
  String get eventLocationDateTime {
    return '$location - $formattedStartDate $startTime';
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      thumbnail: json['thumbnail'],
      title: json['title'],
      description: json['description'],
      startDate: json['start_date'],
      startTime: json['start_time'],
      duration: json['duration'],
      endDate: json['end_date'],
      endTime: json['end_time'],
      endDateTime: json['end_date_time'],
      city: json['city'],
      country: json['country'],
      address: json['address'],
      zipCode: json['zip_code'],
      categoryName: json['category_name'],
      categoryId: json['category_id'],
      organizerId: json['organizer_id'],
      organizerName: json['organizer_name'],
      price: json['price'],
    );
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}

/* class Category {
  final int id;
  final String name;
  final String slug;
  final int languageId;
  final String image;
  final int serialNumber;
  final String isFeatured;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.languageId,
    required this.image,
    required this.serialNumber,
    required this.isFeatured,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      languageId: json['language_id'],
      image: json['image'],
      serialNumber: json['serial_number'],
      isFeatured: json['is_featured'],
    );
  } 
} */