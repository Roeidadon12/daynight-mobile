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
  String? description; // Main event description (plain text)
  String? enDescription; // English description (for multi-language support)
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
  
  // Language-specific fields (Hebrew)
  String? heTitle;
  int? heCategoryId;
  String? heDescription;
  String? heDescriptionHtml;
  String? heDescriptionRaw;
  String? heCountry;
  String? heRefundPolicy;
  String? heMetaKeywords;
  String? heMetaDescription;
  
  // Language-specific fields (English)
  String? enTitle;
  int? enCategoryId;
  String? enDescriptionText;
  String? enDescriptionHtml;
  String? enDescriptionRaw;
  String? enCountry;
  String? enRefundPolicy;
  String? enMetaKeywords;
  String? enMetaDescription;
  
  // Date/Time string formats (for API)
  String? startDateStr;
  String? startTimeStr;
  String? endDateStr;
  String? endTimeStr;
  
  // Localization settings
  String? timezone;
  String? currency;
  String? language;
  
  // Step 3 fields
  bool? isPrivateEvent;
  String? urlSuffix;
  String? organizerName;
  String? trackingField1;
  String? trackingField2;
  String? trackingField3;
  String? trackingField4;

  CreateEventData({
    this.eventName = '',
    this.location = '',
    this.category,
    this.minimalAge,
    this.startTime,
    this.endTime,
    this.capacity,
    this.description,
    this.enDescription,
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
    // Language-specific fields
    this.heTitle,
    this.heCategoryId,
    this.heDescription,
    this.heDescriptionHtml,
    this.heDescriptionRaw,
    this.heCountry,
    this.heRefundPolicy,
    this.heMetaKeywords,
    this.heMetaDescription,
    this.enTitle,
    this.enCategoryId,
    this.enDescriptionText,
    this.enDescriptionHtml,
    this.enDescriptionRaw,
    this.enCountry,
    this.enRefundPolicy,
    this.enMetaKeywords,
    this.enMetaDescription,
    // Date/Time formats
    this.startDateStr,
    this.startTimeStr,
    this.endDateStr,
    this.endTimeStr,
    // Localization
    this.timezone,
    this.currency,
    this.language,
    // Step 3 fields
    this.isPrivateEvent,
    this.urlSuffix,
    this.organizerName,
    this.trackingField1,
    this.trackingField2,
    this.trackingField3,
    this.trackingField4,
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
        ticketTypes.every(
          (ticket) => ticket.name.isNotEmpty && ticket.quantity > 0,
        );
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
      'address': location, // Add alias for backward compatibility
      'category': category,
      'minimalAge': minimalAge,
      'min_age': minimalAge, // Add alias for backward compatibility
      'startTime': startTime,
      'endTime': endTime,
      'capacity': capacity,
      'description': description,
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
      // Language-specific fields (Hebrew)
      'he_title': heTitle,
      'he_category_id': heCategoryId,
      'he_description': heDescription,
      'he_descriptionHtml': heDescriptionHtml,
      'he_descriptionRaw': heDescriptionRaw,
      'he_country': heCountry,
      'he_refund_policy': heRefundPolicy,
      'he_meta_keywords': heMetaKeywords,
      'he_meta_description': heMetaDescription,
      // Language-specific fields (English)
      'en_title': enTitle,
      'en_category_id': enCategoryId,
      'en_description': enDescriptionText,
      'en_descriptionHtml': enDescriptionHtml,
      'en_descriptionRaw': enDescriptionRaw,
      'en_country': enCountry,
      'en_refund_policy': enRefundPolicy,
      'en_meta_keywords': enMetaKeywords,
      'en_meta_description': enMetaDescription,
      // Date/Time string formats
      'start_date': startDateStr,
      'start_time': startTimeStr,
      'end_date': endDateStr,
      'end_time': endTimeStr,
      // Localization
      'timezone': timezone,
      'currency': currency,
      'language': language,
      // Step 3 fields
      'isPrivateEvent': isPrivateEvent,
      'urlSuffix': urlSuffix,
      'organizerName': organizerName,
      'trackingField1': trackingField1,
      'trackingField2': trackingField2,
      'trackingField3': trackingField3,
      'trackingField4': trackingField4,
    };
  }

  /// Convert to JSON for API submission
  Map<String, dynamic> toApiJson(Map<String, dynamic> additionalData) {
    // Use saved date/time strings if available, otherwise format from DateTime objects
    final startDateStrFinal = startDateStr ?? 
        startTime?.toIso8601String().split('T')[0]; // Format: 2024-05-13
    final startTimeStrFinal = startTimeStr ?? 
        (startTime != null
            ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
            : null); // Format: 21:00
    final endDateStrFinal = endDateStr ?? 
        endTime?.toIso8601String().split('T')[0]; // Format: 2024-11-29
    final endTimeStrFinal = endTimeStr ?? 
        (endTime != null
            ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
            : null); // Format: 08:00

    // Get additional fields from form data
    String slug = urlSuffix ?? additionalData['urlSuffix'] ?? '';
    if (slug.isEmpty) {
      // Generate slug from event name if urlSuffix is empty
      slug = (heTitle ?? enTitle ?? eventName)
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-')
          .trim();
    }

    // Build base API data
    final apiData = {
      // Required fields
      'status': 1, // integer - Event status
      'cover_image': image ?? '', // file - Event cover image
      'min_age': minimalAge ?? 0, // integer - Minimum age of participant, min value 0
      'countdown_status': 1, // integer - Event start date countdown status 1=active, 0=deactive
      'is_featured': 'no', // string - Values = yes/no
      'date_type': 'single', // string - Values = single/multiple
      // Single date fields (when date_type=single)
      'start_date': startDateStrFinal ?? '', // string - Format = 2024-05-13
      'start_time': startTimeStrFinal ?? '', // string - Format = 21:00
      'end_date': endDateStrFinal ?? '', // string - Format = 2024-11-29
      'end_time': endTimeStrFinal ?? '', // string - Format = 08:00
      'end_date_time_status': 1, // integer - 1=show end date time, 0=hide end date time
      // Multiple date fields (when date_type=multiple) - empty arrays for single events
      'm_start_date': [], // array - Format = 2025-12-12
      'm_start_time': [], // array - Format = 12:10
      'm_end_date': [], // array - Format = 2026-01-03
      'm_end_time': [], // array - Format = 12:11
      // Map and address
      'map_status': 1, // integer - 1=Enable, 0=Disable
      'address': location, // string
      'map_address': location, // string - same as address for now
      // Tracking fields (optional)
      'pixel_id': trackingField1 ?? additionalData['trackingField1'] ?? '', // string - Meta pixel id
      'tiktok_pixel_id': trackingField2 ?? additionalData['trackingField2'] ?? '', // string - Tiktok pixel id
      'measurement_id': trackingField3 ?? additionalData['trackingField3'] ?? '', // string - GA-4 Analytics
      // Slug
      'slug': slug, // string - unique slug for event
      // Language-specific fields (Hebrew)
      'he_title': heTitle ?? '',
      'he_category_id': heCategoryId ?? '',
      'he_description': heDescriptionHtml ?? heDescription ?? '',
      'he_country': heCountry ?? '',
      'he_refund_policy': heRefundPolicy ?? '',
      'he_meta_keywords': heMetaKeywords ?? '',
      'he_meta_description': heMetaDescription ?? '',
      // Language-specific fields (English)
      'en_title': enTitle ?? '',
      'en_category_id': enCategoryId ?? '',
      'en_description': enDescriptionHtml ?? enDescriptionText ?? '',
      'en_country': enCountry ?? '',
      'en_refund_policy': enRefundPolicy ?? '',
      'en_meta_keywords': enMetaKeywords ?? '',
      'en_meta_description': enMetaDescription ?? '',
    };

    // Remove all null and empty string values from the API data
    apiData.removeWhere((key, value) {
      if (value == null) return true;
      if (value is String && value.isEmpty) return true;
      if (value is List && value.isEmpty) return true;
      return false;
    });

    return apiData;
  }

  /// Convert to JSON for backward compatibility
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
    // Extract eventName from language-specific title fields (he_title or en_title)
    String extractedEventName = map['eventName'] as String? ?? 
                                map['he_title'] as String? ?? 
                                map['en_title'] as String? ?? '';
    
    // Extract location from address field
    String extractedLocation = map['location'] as String? ?? 
                               map['address'] as String? ?? '';
    
    // Extract minimalAge
    int? extractedMinAge = map['minimalAge'] as int? ?? 
                           map['min_age'] as int?;
    
    // Reconstruct DateTime from date/time strings if available
    DateTime? extractedStartTime = map['startTime'] as DateTime?;
    DateTime? extractedEndTime = map['endTime'] as DateTime?;
    
    // If DateTime objects not found, try to reconstruct from date/time strings
    if (extractedStartTime == null) {
      final startDate = map['start_date'] as String?;
      final startTime = map['start_time'] as String?;
      if (startDate != null && startTime != null) {
        try {
          final dateParts = startDate.split('-');
          final timeParts = startTime.split(':');
          if (dateParts.length == 3 && timeParts.length == 2) {
            extractedStartTime = DateTime(
              int.parse(dateParts[0]), // year
              int.parse(dateParts[1]), // month
              int.parse(dateParts[2]), // day
              int.parse(timeParts[0]), // hour
              int.parse(timeParts[1]), // minute
            );
          }
        } catch (e) {
          // Failed to parse, leave as null
        }
      }
    }
    
    if (extractedEndTime == null) {
      final endDate = map['end_date'] as String?;
      final endTime = map['end_time'] as String?;
      if (endDate != null && endTime != null) {
        try {
          final dateParts = endDate.split('-');
          final timeParts = endTime.split(':');
          if (dateParts.length == 3 && timeParts.length == 2) {
            extractedEndTime = DateTime(
              int.parse(dateParts[0]), // year
              int.parse(dateParts[1]), // month
              int.parse(dateParts[2]), // day
              int.parse(timeParts[0]), // hour
              int.parse(timeParts[1]), // minute
            );
          }
        } catch (e) {
          // Failed to parse, leave as null
        }
      }
    }
    
    // Extract description (prefer language-specific descriptions)
    final description = map['description'] as String? ?? 
                       map['he_description'] as String? ?? 
                       map['en_description'] as String?;
    
    return CreateEventData(
      eventName: extractedEventName,
      location: extractedLocation,
      category: map['category'] as Category?,
      minimalAge: extractedMinAge,
      startTime: extractedStartTime,
      endTime: extractedEndTime,
      capacity: map['capacity'] as int?,
      description: description,
      additionalInfo: map['additionalInfo'] as String?,
      image: map['image'] as String?,
      isPublic: map['isPublic'] ?? true,
      allowRegistration: map['allowRegistration'] ?? true,
      sendReminders: map['sendReminders'] ?? true,
      isFreeEvent: map['isFreeEvent'] ?? false,
      ticketTypes:
          (map['ticketTypes'] as List?)?.map((item) {
            if (item is CreateEventTicketType) return item;
            if (item is Map<String, dynamic>) {
              return CreateEventTicketType.fromJson(item);
            }
            return CreateEventTicketType(name: '', price: 0, quantity: 1);
          }).toList() ??
          [],
      createdAt: map['createdAt'] as DateTime?,
      updatedAt: map['updatedAt'] as DateTime?,
      status: map['status'] ?? 'draft',
      // Language-specific fields (Hebrew)
      heTitle: map['he_title'] as String?,
      heCategoryId: map['he_category_id'] as int?,
      heDescription: map['he_description'] as String?,
      heDescriptionHtml: map['he_descriptionHtml'] as String?,
      heDescriptionRaw: map['he_descriptionRaw'] as String?,
      heCountry: map['he_country'] as String?,
      heRefundPolicy: map['he_refund_policy'] as String?,
      heMetaKeywords: map['he_meta_keywords'] as String?,
      heMetaDescription: map['he_meta_description'] as String?,
      // Language-specific fields (English)
      enTitle: map['en_title'] as String?,
      enCategoryId: map['en_category_id'] as int?,
      enDescriptionText: map['en_description'] as String?,
      enDescriptionHtml: map['en_descriptionHtml'] as String?,
      enDescriptionRaw: map['en_descriptionRaw'] as String?,
      enCountry: map['en_country'] as String?,
      enRefundPolicy: map['en_refund_policy'] as String?,
      enMetaKeywords: map['en_meta_keywords'] as String?,
      enMetaDescription: map['en_meta_description'] as String?,
      // Date/Time string formats
      startDateStr: map['start_date'] as String?,
      startTimeStr: map['start_time'] as String?,
      endDateStr: map['end_date'] as String?,
      endTimeStr: map['end_time'] as String?,
      // Localization
      timezone: map['timezone'] as String?,
      currency: map['currency'] as String?,
      language: map['language'] as String?,
      // Step 3 fields
      isPrivateEvent: map['isPrivateEvent'] as bool?,
      urlSuffix: map['urlSuffix'] as String?,
      organizerName: map['organizerName'] as String?,
      trackingField1: map['trackingField1'] as String?,
      trackingField2: map['trackingField2'] as String?,
      trackingField3: map['trackingField3'] as String?,
      trackingField4: map['trackingField4'] as String?,
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
    String? description,
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
      description: description ?? this.description,
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
      case 'address': // Also accept 'address' as an alias for 'location'
        location = value ?? '';
        break;
      case 'category':
        category = value as Category?;
        break;
      case 'minimalAge':
      case 'min_age': // Also accept 'min_age' as an alias for 'minimalAge'
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
      case 'description':
        description = value as String?;
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
      // Language-specific fields (Hebrew)
      case 'he_title':
        heTitle = value as String?;
        break;
      case 'he_category_id':
        heCategoryId = value as int?;
        break;
      case 'he_description':
        heDescription = value as String?;
        break;
      case 'he_descriptionHtml':
        heDescriptionHtml = value as String?;
        break;
      case 'he_descriptionRaw':
        heDescriptionRaw = value as String?;
        break;
      case 'he_country':
        heCountry = value as String?;
        break;
      case 'he_refund_policy':
        heRefundPolicy = value as String?;
        break;
      case 'he_meta_keywords':
        heMetaKeywords = value as String?;
        break;
      case 'he_meta_description':
        heMetaDescription = value as String?;
        break;
      // Language-specific fields (English)
      case 'en_title':
        enTitle = value as String?;
        break;
      case 'en_category_id':
        enCategoryId = value as int?;
        break;
      case 'en_description':
        enDescriptionText = value as String?;
        break;
      case 'en_descriptionHtml':
        enDescriptionHtml = value as String?;
        break;
      case 'en_descriptionRaw':
        enDescriptionRaw = value as String?;
        break;
      case 'en_country':
        enCountry = value as String?;
        break;
      case 'en_refund_policy':
        enRefundPolicy = value as String?;
        break;
      case 'en_meta_keywords':
        enMetaKeywords = value as String?;
        break;
      case 'en_meta_description':
        enMetaDescription = value as String?;
        break;
      // Date/Time string formats
      case 'start_date':
        startDateStr = value as String?;
        break;
      case 'start_time':
        startTimeStr = value as String?;
        break;
      case 'end_date':
        endDateStr = value as String?;
        break;
      case 'end_time':
        endTimeStr = value as String?;
        break;
      // Localization
      case 'timezone':
        timezone = value as String?;
        break;
      case 'currency':
        currency = value as String?;
        break;
      case 'language':
        language = value as String?;
        break;
      // Step 3 fields
      case 'isPrivateEvent':
        isPrivateEvent = value as bool?;
        break;
      case 'urlSuffix':
        urlSuffix = value as String?;
        break;
      case 'organizerName':
        organizerName = value as String?;
        break;
      case 'trackingField1':
        trackingField1 = value as String?;
        break;
      case 'trackingField2':
        trackingField2 = value as String?;
        break;
      case 'trackingField3':
        trackingField3 = value as String?;
        break;
      case 'trackingField4':
        trackingField4 = value as String?;
        break;
      default:
        // Unknown field - ignore or log warning
        break;
    }
    updatedAt = DateTime.now();
  }

  /// Get all language-specific fields for debugging
  Map<String, dynamic> getLanguageFields() {
    return {
      'he_title': heTitle,
      'he_category_id': heCategoryId,
      'he_description': heDescription,
      'he_descriptionHtml': heDescriptionHtml,
      'he_descriptionRaw': heDescriptionRaw,
      'he_country': heCountry,
      'he_refund_policy': heRefundPolicy,
      'he_meta_keywords': heMetaKeywords,
      'he_meta_description': heMetaDescription,
      'en_title': enTitle,
      'en_category_id': enCategoryId,
      'en_description': enDescriptionText,
      'en_descriptionHtml': enDescriptionHtml,
      'en_descriptionRaw': enDescriptionRaw,
      'en_country': enCountry,
      'en_refund_policy': enRefundPolicy,
      'en_meta_keywords': enMetaKeywords,
      'en_meta_description': enMetaDescription,
    };
  }

  @override
  String toString() {
    return 'CreateEventData(\n'
        '  eventName: $eventName (he: "${heTitle ?? ''}", en: "${enTitle ?? ''}"),\n'
        '  location: $location,\n'
        '  category: ${category?.name},\n'
        '  he_category_id: $heCategoryId,\n'
        '  en_category_id: $enCategoryId,\n'
        '  startTime: $startTime,\n'
        '  endTime: $endTime,\n'
        '  minAge: $minimalAge,\n'
        '  capacity: $capacity,\n'
        '  timezone: $timezone,\n'
        '  currency: $currency,\n'
        '  isValid: $isValid\n'
        ')';
  }
}
