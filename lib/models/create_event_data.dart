import '../models/category.dart';

/// Represents a ticket type for an event
class CreateEventTicketType {
  String name;
  double price;
  int quantity;
  String description;

  CreateEventTicketType({
    required this.name,
    required this.price,
    required this.quantity,
    this.description = '',
  });

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
    };
  }

  /// Create from JSON
  factory CreateEventTicketType.fromJson(Map<String, dynamic> json) {
    return CreateEventTicketType(
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      description: json['description'] ?? '',
    );
  }

  /// Create a copy with updated values
  CreateEventTicketType copyWith({
    String? name,
    double? price,
    int? quantity,
    String? description,
  }) {
    return CreateEventTicketType(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
    );
  }
}

/// Comprehensive model to hold all event creation data
class CreateEventData {
  // Step 1: Basic Information
  String eventName;
  String location;
  Category? category;
  int? minimalAge;
  DateTime? startTime;
  DateTime? endTime;

  // Step 2: Event Description & Settings  
  int? capacity;
  String? additionalInfo;
  String? image; // Image URL or path
  bool isPublic;
  bool allowRegistration;
  bool sendReminders;

  // Step 3: Tickets & Pricing
  bool isFreeEvent;
  List<CreateEventTicketType> ticketTypes;

  // Additional metadata
  DateTime? createdAt;
  DateTime? updatedAt;
  String? status; // 'draft', 'published', etc.

  CreateEventData({
    this.eventName = '',
    this.location = '',
    this.category,
    this.minimalAge,
    this.startTime,
    this.endTime,
    this.capacity,
    this.additionalInfo,
    this.image,
    this.isPublic = true,
    this.allowRegistration = true,
    this.sendReminders = true,
    this.isFreeEvent = false,
    List<CreateEventTicketType>? ticketTypes,
    this.createdAt,
    this.updatedAt,
    this.status = 'draft',
  }) : ticketTypes = ticketTypes ?? [];

  /// Check if Step 1 (Basic Info) is valid
  bool get isStep1Valid {
    return eventName.isNotEmpty &&
           location.isNotEmpty &&
           category != null &&
           startTime != null &&
           endTime != null;
  }

  /// Check if Step 2 (Description & Settings) is valid
  bool get isStep2Valid {
    return capacity != null && capacity! > 0;
  }

  /// Check if Step 3 (Tickets & Pricing) is valid
  bool get isStep3Valid {
    if (isFreeEvent) return true;
    
    return ticketTypes.isNotEmpty && 
           ticketTypes.every((ticket) => 
               ticket.name.isNotEmpty && 
               ticket.quantity > 0);
  }

  /// Check if all steps are valid for event creation
  bool get isValid {
    return isStep1Valid && isStep2Valid && isStep3Valid;
  }

  /// Get event duration in hours
  double? get durationInHours {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!).inMinutes / 60.0;
  }

  /// Get total ticket quantity across all ticket types
  int get totalTicketQuantity {
    if (isFreeEvent) return capacity ?? 0;
    return ticketTypes.fold(0, (sum, ticket) => sum + ticket.quantity);
  }

  /// Get minimum ticket price (0 for free events)
  double get minTicketPrice {
    if (isFreeEvent || ticketTypes.isEmpty) return 0.0;
    return ticketTypes.map((t) => t.price).reduce((a, b) => a < b ? a : b);
  }

  /// Get maximum ticket price (0 for free events)  
  double get maxTicketPrice {
    if (isFreeEvent || ticketTypes.isEmpty) return 0.0;
    return ticketTypes.map((t) => t.price).reduce((a, b) => a > b ? a : b);
  }

  /// Convert to Map for backward compatibility with existing code
  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'location': location,
      'category': category,
      'minimalAge': minimalAge,
      'startTime': startTime,
      'endTime': endTime,
      'capacity': capacity,
      'additionalInfo': additionalInfo,
      'image': image,
      'isPublic': isPublic,
      'allowRegistration': allowRegistration,
      'sendReminders': sendReminders,
      'isFreeEvent': isFreeEvent,
      'ticketTypes': ticketTypes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
    };
  }

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'title': eventName,
      'address': location,
      'category_id': category?.id,
      'min_age': minimalAge,
      'start_date_time': startTime?.toIso8601String(),
      'end_date_time': endTime?.toIso8601String(),
      'capacity': capacity,
      'description': additionalInfo ?? '',
      'cover_image': image,
      'is_public': isPublic ? 1 : 0,
      'allow_registration': allowRegistration ? 1 : 0,
      'send_reminders': sendReminders ? 1 : 0,
      'is_free': isFreeEvent ? 1 : 0,
      'tickets': ticketTypes.map((ticket) => ticket.toJson()).toList(),
      'status': status,
    };
  }

  /// Create from Map (for loading existing data)
  factory CreateEventData.fromMap(Map<String, dynamic> map) {
    return CreateEventData(
      eventName: map['eventName'] ?? '',
      location: map['location'] ?? '',
      category: map['category'] as Category?,
      minimalAge: map['minimalAge'] as int?,
      startTime: map['startTime'] as DateTime?,
      endTime: map['endTime'] as DateTime?,
      capacity: map['capacity'] as int?,
      additionalInfo: map['additionalInfo'] as String?,
      image: map['image'] as String?,
      isPublic: map['isPublic'] ?? true,
      allowRegistration: map['allowRegistration'] ?? true,
      sendReminders: map['sendReminders'] ?? true,
      isFreeEvent: map['isFreeEvent'] ?? false,
      ticketTypes: (map['ticketTypes'] as List?)
          ?.map((item) {
            if (item is CreateEventTicketType) return item;
            if (item is Map<String, dynamic>) return CreateEventTicketType.fromJson(item);
            return CreateEventTicketType(name: '', price: 0, quantity: 1);
          })
          .toList() ?? [],
      createdAt: map['createdAt'] as DateTime?,
      updatedAt: map['updatedAt'] as DateTime?,
      status: map['status'] ?? 'draft',
    );
  }

  /// Create a copy with updated values
  CreateEventData copyWith({
    String? eventName,
    String? location,
    Category? category,
    int? minimalAge,
    DateTime? startTime,
    DateTime? endTime,
    int? capacity,
    String? additionalInfo,
    String? image,
    bool? isPublic,
    bool? allowRegistration,
    bool? sendReminders,
    bool? isFreeEvent,
    List<CreateEventTicketType>? ticketTypes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return CreateEventData(
      eventName: eventName ?? this.eventName,
      location: location ?? this.location,
      category: category ?? this.category,
      minimalAge: minimalAge ?? this.minimalAge,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      image: image ?? this.image,
      isPublic: isPublic ?? this.isPublic,
      allowRegistration: allowRegistration ?? this.allowRegistration,
      sendReminders: sendReminders ?? this.sendReminders,
      isFreeEvent: isFreeEvent ?? this.isFreeEvent,
      ticketTypes: ticketTypes ?? this.ticketTypes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  /// Clear all data (reset to defaults)
  void clear() {
    eventName = '';
    location = '';
    category = null;
    minimalAge = null;
    startTime = null;
    endTime = null;
    capacity = null;
    additionalInfo = null;
    image = null;
    isPublic = true;
    allowRegistration = true;
    sendReminders = true;
    isFreeEvent = false;
    ticketTypes.clear();
    createdAt = null;
    updatedAt = null;
    status = 'draft';
  }

  /// Update a specific field (for backward compatibility)
  void updateField(String key, dynamic value) {
    switch (key) {
      case 'eventName':
        eventName = value ?? '';
        break;
      case 'location':
        location = value ?? '';
        break;
      case 'category':
        category = value as Category?;
        break;
      case 'minimalAge':
        minimalAge = value as int?;
        break;
      case 'startTime':
        startTime = value as DateTime?;
        break;
      case 'endTime':
        endTime = value as DateTime?;
        break;
      case 'capacity':
        capacity = value as int?;
        break;
      case 'additionalInfo':
        additionalInfo = value as String?;
        break;
      case 'image':
        image = value as String?;
        break;
      case 'isPublic':
        isPublic = value ?? true;
        break;
      case 'allowRegistration':
        allowRegistration = value ?? true;
        break;
      case 'sendReminders':
        sendReminders = value ?? true;
        break;
      case 'isFreeEvent':
        isFreeEvent = value ?? false;
        break;
      case 'ticketTypes':
        if (value is List<CreateEventTicketType>) {
          ticketTypes = value;
        }
        break;
      case 'status':
        status = value ?? 'draft';
        break;
    }
    updatedAt = DateTime.now();
  }

  @override
  String toString() {
    return 'CreateEventData(eventName: $eventName, location: $location, category: ${category?.name}, isValid: $isValid)';
  }
}