
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
    late Events event;

    try {
        event = Events(
          currentPage: json['current_page'] ?? 1,
          data: (json['data'] as List? ?? []).map((event) => Event.fromJson(event)).toList(),
          firstPageUrl: json['first_page_url'] ?? '',
          from: json['from'] ?? 0,
          lastPage: json['last_page'] ?? 1,
          lastPageUrl: json['last_page_url'] ?? '',
          links: (json['links'] as List? ?? [])
              .map((link) => PaginationLink.fromJson(link))
              .toList(),
          nextPageUrl: json['next_page_url'],
          path: json['path'] ?? '',
          perPage: json['per_page'] ?? 10,
          prevPageUrl: json['prev_page_url'],
          to: json['to'] ?? 0,
          total: json['total'] ?? 0,
        );
    }
    catch (e) {
      rethrow;
    }
  
    return event;
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
    if (address.isNotEmpty) {
      return address;
    }
    else if (city != null && city!.isNotEmpty) {
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

/// Represents a simplified event model for the organizer's dashboard
/// Contains basic event info and permission flags for event management
class OrganizerEvent {
  final int id;
  final String title;
  final String category;
  
  // Permission flags
  final bool canAccessBookings;
  final bool canAccessReport;
  final bool canAccessTeam;
  final bool canAccessLinks;
  final bool canAccessTicket;
  final bool canAccessStatistics;
  final bool canSendFreeTicket;
  final bool canFeaturedEvent;
  final bool canAccessCoupons;
  final bool canEditEvent;
  final bool canSendSms;

  OrganizerEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.canAccessBookings,
    required this.canAccessReport,
    required this.canAccessTeam,
    required this.canAccessLinks,
    required this.canAccessTicket,
    required this.canAccessStatistics,
    required this.canSendFreeTicket,
    required this.canFeaturedEvent,
    required this.canAccessCoupons,
    required this.canEditEvent,
    required this.canSendSms,
  });

  /// Creates an OrganizerEvent from JSON
  factory OrganizerEvent.fromJson(Map<String, dynamic> json) {
    return OrganizerEvent(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      canAccessBookings: _parseBooleanString(json['can_access_bookings']),
      canAccessReport: _parseBooleanString(json['can_access_report']),
      canAccessTeam: _parseBooleanString(json['can_access_team']),
      canAccessLinks: _parseBooleanString(json['can_access_links']),
      canAccessTicket: _parseBooleanString(json['can_access_ticket']),
      canAccessStatistics: _parseBooleanString(json['can_access_statistics']),
      canSendFreeTicket: _parseBooleanString(json['can_send_free_ticket']),
      canFeaturedEvent: _parseBooleanString(json['can_featured_event']),
      canAccessCoupons: _parseBooleanString(json['can_access_coupons']),
      canEditEvent: _parseBooleanString(json['can_edit_event']),
      canSendSms: _parseBooleanString(json['can_send_sms']),
    );
  }

  /// Converts the OrganizerEvent to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'can_access_bookings': canAccessBookings ? 'yes' : 'no',
      'can_access_report': canAccessReport ? 'yes' : 'no',
      'can_access_team': canAccessTeam ? 'yes' : 'no',
      'can_access_links': canAccessLinks ? 'yes' : 'no',
      'can_access_ticket': canAccessTicket ? 'yes' : 'no',
      'can_access_statistics': canAccessStatistics ? 'yes' : 'no',
      'can_send_free_ticket': canSendFreeTicket ? 'yes' : 'no',
      'can_featured_event': canFeaturedEvent ? 'yes' : 'no',
      'can_access_coupons': canAccessCoupons ? 'yes' : 'no',
      'can_edit_event': canEditEvent ? 'yes' : 'no',
      'can_send_sms': canSendSms ? 'yes' : 'no',
    };
  }

  /// Helper method to parse "yes"/"no" strings to boolean
  static bool _parseBooleanString(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'yes';
    }
    return false;
  }

  /// Check if user has full access to the event
  bool get hasFullAccess {
    return canAccessBookings &&
        canAccessReport &&
        canAccessTeam &&
        canAccessLinks &&
        canAccessTicket &&
        canAccessStatistics &&
        canEditEvent;
  }

  /// Check if user can manage event content
  bool get canManageContent {
    return canEditEvent && canAccessLinks;
  }

  /// Check if user can manage marketing
  bool get canManageMarketing {
    return canSendFreeTicket && canAccessCoupons && canSendSms;
  }

  @override
  String toString() {
    return 'OrganizerEvent(id: $id, title: $title, category: $category)';
  }
}
