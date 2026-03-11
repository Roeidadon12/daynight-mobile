import 'ticket.dart';
import 'related_event.dart';
import 'organizer.dart';
import 'language.dart';

class EventDetails {
  final String status;
  final EventInformation eventInformation;
  final Organizer? organizer;
  final List<RelatedEvent> relatedEvents;
  final List<Ticket> tickets;

  EventDetails({
    required this.status,
    required this.eventInformation,
    this.organizer,
    required this.relatedEvents,
    required this.tickets,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      status: json['status'],
      eventInformation: EventInformation.fromJson(json['event_information']),
      organizer: _parseOrganizer(json['organizer']),
      relatedEvents: (json['related_events'] as List)
          .map((event) => RelatedEvent.fromJson(event))
          .toList(),
      tickets: (json['tickets'] as List)
          .map((ticket) => Ticket.fromJson(ticket))
          .toList(),
    );
  }

  static Organizer? _parseOrganizer(dynamic organizerData) {
    if (organizerData == null) return null;
    if (organizerData is String && organizerData.isEmpty) return null;
    if (organizerData is Map<String, dynamic>) {
      return Organizer.fromJson(organizerData);
    }
    return null;
  }
}

class EventInformation {
  final int id;
  final String title;
  final String description;
  final String? enDescription;
  final int eventCategoryId;
  final String name;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String country;
  final String address;
  final String? zipCode;
  final String? refundPolicy;
  final int? organizerId;
  final String status;
  final String dateType;
  final int countdownStatus;
  final String startDate;
  final String startTime;
  final String duration;
  final String endDate;
  final String endTime;
  final String endDateTime;
  final String isFeatured;
  final int minAge;
  final int isRequiredIdNumber;
  final int isRequiredFacebookUsername;
  final int isRequiredInstagramUsername;
  final int isRequiredFacebookOrInstagram;
  final int imageOfIdStatus;
  final String coverImage;
  final int mapStatus;
  final String mapAddress;
  final int prcessingFeeStatus;
  final String prcessingFeeType;
  final int prcessingFee;

  EventInformation({
    required this.id,
    required this.title,
    required this.description,
    this.enDescription,
    required this.eventCategoryId,
    required this.name,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    required this.country,
    required this.address,
    this.zipCode,
    this.refundPolicy,
    this.organizerId,
    required this.status,
    required this.dateType,
    required this.countdownStatus,
    required this.startDate,
    required this.startTime,
    required this.duration,
    required this.endDate,
    required this.endTime,
    required this.endDateTime,
    required this.isFeatured,
    required this.minAge,
    required this.isRequiredIdNumber,
    required this.isRequiredFacebookUsername,
    required this.isRequiredInstagramUsername,
    required this.isRequiredFacebookOrInstagram,
    required this.imageOfIdStatus,
    required this.coverImage,
    required this.mapStatus,
    required this.mapAddress,
    required this.prcessingFeeStatus,
    required this.prcessingFeeType,
    required this.prcessingFee,
  });

  factory EventInformation.fromJson(Map<String, dynamic> json) {
    return EventInformation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      enDescription: json['description'],
      eventCategoryId: json['event_category_id'],
      name: json['name'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      city: json['city'],
      state: json['state'],
      country: json['country'],
      address: json['address'],
      zipCode: json['zip_code'],
      refundPolicy: json['refund_policy'],
      organizerId: json['organizer_id'],
      status: json['status'],
      dateType: json['date_type'],
      countdownStatus: json['countdown_status'],
      startDate: json['start_date'],
      startTime: json['start_time'],
      duration: json['duration'],
      endDate: json['end_date'],
      endTime: json['end_time'],
      endDateTime: json['end_date_time'],
      isFeatured: json['is_featured'],
      minAge: json['min_age'],
      isRequiredIdNumber: json['is_required_id_number'] ?? 0,
      isRequiredFacebookUsername: json['is_required_facebook_username'] ?? 0,
      isRequiredInstagramUsername: json['is_required_instagram_username'] ?? 0,
      isRequiredFacebookOrInstagram: json['is_required_facebook_or_instagram'] ?? 0,
      imageOfIdStatus: json['image_of_id_status'],
      coverImage: json['cover_image'],
      mapStatus: json['map_status'],
      mapAddress: json['map_address'],
      prcessingFeeStatus: json['prcessing_fee_status'],
      prcessingFeeType: json['prcessing_fee_type'],
      prcessingFee: json['prcessing_fee'],
    );
  }
}

class EventEditDetails {
  final EditEvent event;
  final EventCurrencyInfo? currencyInfo;
  final List<Language> languages;
  final EventLanguageContent? enEventContent;
  final EventLanguageContent? heEventContent;
  final String? address;

  EventEditDetails({
    required this.event,
    required this.currencyInfo,
    required this.languages,
    required this.enEventContent,
    required this.heEventContent,
    required this.address,
  });

  factory EventEditDetails.fromJson(Map<String, dynamic> json) {
    return EventEditDetails(
      event: EditEvent.fromJson(json['event'] as Map<String, dynamic>),
      currencyInfo: json['getCurrencyInfo'] is Map<String, dynamic>
          ? EventCurrencyInfo.fromJson(json['getCurrencyInfo'] as Map<String, dynamic>)
          : null,
      languages: (json['languages'] as List<dynamic>? ?? const [])
          .map((item) => Language.fromJson(item as Map<String, dynamic>))
          .toList(),
      enEventContent: json['en_event_content'] is Map<String, dynamic>
          ? EventLanguageContent.fromJson(json['en_event_content'] as Map<String, dynamic>)
          : null,
      heEventContent: json['he_event_content'] is Map<String, dynamic>
          ? EventLanguageContent.fromJson(json['he_event_content'] as Map<String, dynamic>)
          : null,
      address: json['address'] as String?,
    );
  }
}

class EditEvent {
  final int id;
  final int organizerId;
  final String thumbnail;
  final String status;
  final String dateType;
  final int countdownStatus;
  final String startDate;
  final String startTime;
  final String duration;
  final String endDate;
  final String endTime;
  final String endDateTime;
  final String? createdAt;
  final String? updatedAt;
  final String eventType;
  final String isFeatured;
  final double? latitude;
  final double? longitude;
  final int minAge;
  final int? isRequiredIdNumber;
  final int isRequiredFacebookUsername;
  final int isRequiredInstagramUsername;
  final String coverImage;
  final int mapStatus;
  final String? mapAddress;
  final int isRequiredFacebookOrInstagram;
  final int autoTicketApproval;
  final int taxStatus;
  final String? taxType;
  final double? taxAmount;
  final int imageOfIdStatus;
  final int? measurementId;
  final String? pixelId;
  final String? tiktokPixelId;
  final int hideDuration;
  final int hideGeneralStatsStatus;
  final int hideProgressBarStatus;
  final dynamic selectedTickets;
  final int serialNumber;

  EditEvent({
    required this.id,
    required this.organizerId,
    required this.thumbnail,
    required this.status,
    required this.dateType,
    required this.countdownStatus,
    required this.startDate,
    required this.startTime,
    required this.duration,
    required this.endDate,
    required this.endTime,
    required this.endDateTime,
    required this.createdAt,
    required this.updatedAt,
    required this.eventType,
    required this.isFeatured,
    required this.latitude,
    required this.longitude,
    required this.minAge,
    required this.isRequiredIdNumber,
    required this.isRequiredFacebookUsername,
    required this.isRequiredInstagramUsername,
    required this.coverImage,
    required this.mapStatus,
    required this.mapAddress,
    required this.isRequiredFacebookOrInstagram,
    required this.autoTicketApproval,
    required this.taxStatus,
    required this.taxType,
    required this.taxAmount,
    required this.imageOfIdStatus,
    required this.measurementId,
    required this.pixelId,
    required this.tiktokPixelId,
    required this.hideDuration,
    required this.hideGeneralStatsStatus,
    required this.hideProgressBarStatus,
    required this.selectedTickets,
    required this.serialNumber,
  });

  factory EditEvent.fromJson(Map<String, dynamic> json) {
    return EditEvent(
      id: _asInt(json['id']) ?? 0,
      organizerId: _asInt(json['organizer_id']) ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      status: json['status'] as String? ?? '',
      dateType: json['date_type'] as String? ?? '',
      countdownStatus: _asInt(json['countdown_status']) ?? 0,
      startDate: json['start_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      endDateTime: json['end_date_time'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      eventType: json['event_type'] as String? ?? '',
      isFeatured: json['is_featured'] as String? ?? '',
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      minAge: _asInt(json['min_age']) ?? 0,
      isRequiredIdNumber: _asInt(json['is_required_id_number']),
      isRequiredFacebookUsername: _asInt(json['is_required_facebook_username']) ?? 0,
      isRequiredInstagramUsername: _asInt(json['is_required_instagram_username']) ?? 0,
      coverImage: json['cover_image'] as String? ?? '',
      mapStatus: _asInt(json['map_status']) ?? 0,
      mapAddress: json['map_address'] as String?,
      isRequiredFacebookOrInstagram: _asInt(json['is_required_facebook_or_instagram']) ?? 0,
      autoTicketApproval: _asInt(json['auto_ticket_approval']) ?? 0,
      taxStatus: _asInt(json['tax_status']) ?? 0,
      taxType: json['tax_type'] as String?,
      taxAmount: _asDouble(json['tax_amount']),
      imageOfIdStatus: _asInt(json['image_of_id_status']) ?? 0,
      measurementId: _asInt(json['measurement_id']),
      pixelId: json['pixel_id']?.toString(),
      tiktokPixelId: json['tiktok_pixel_id']?.toString(),
      hideDuration: _asInt(json['hide_duration']) ?? 0,
      hideGeneralStatsStatus: _asInt(json['hide_general_stats_status']) ?? 0,
      hideProgressBarStatus: _asInt(json['hide_progress_bar_status']) ?? 0,
      selectedTickets: json['selected_tickets'],
      serialNumber: _asInt(json['serial_number']) ?? 0,
    );
  }
}

class EventCurrencyInfo {
  final String baseCurrencySymbol;
  final String baseCurrencySymbolPosition;
  final String baseCurrencyText;
  final String baseCurrencyTextPosition;
  final String baseCurrencyRate;

  EventCurrencyInfo({
    required this.baseCurrencySymbol,
    required this.baseCurrencySymbolPosition,
    required this.baseCurrencyText,
    required this.baseCurrencyTextPosition,
    required this.baseCurrencyRate,
  });

  factory EventCurrencyInfo.fromJson(Map<String, dynamic> json) {
    return EventCurrencyInfo(
      baseCurrencySymbol: json['base_currency_symbol'] as String? ?? '',
      baseCurrencySymbolPosition: json['base_currency_symbol_position'] as String? ?? '',
      baseCurrencyText: json['base_currency_text'] as String? ?? '',
      baseCurrencyTextPosition: json['base_currency_text_position'] as String? ?? '',
      baseCurrencyRate: json['base_currency_rate'] as String? ?? '',
    );
  }
}

class EventLanguageContent {
  final int id;
  final int eventId;
  final int languageId;
  final int eventCategoryId;
  final String title;
  final String slug;
  final String description;
  final String? metaKeywords;
  final String? metaDescription;
  final String? createdAt;
  final String? updatedAt;
  final String? address;
  final String? country;
  final String? state;
  final String? city;
  final String? zipCode;
  final String? googleCalendarId;
  final String? refundPolicy;
  final String? titleStatus;
  final String? descriptionStatus;
  final String? countryStatus;
  final String? refundPolicyStatus;
  final String? metaKeywordsStatus;
  final String? metaDescriptionStatus;

  EventLanguageContent({
    required this.id,
    required this.eventId,
    required this.languageId,
    required this.eventCategoryId,
    required this.title,
    required this.slug,
    required this.description,
    required this.metaKeywords,
    required this.metaDescription,
    required this.createdAt,
    required this.updatedAt,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.googleCalendarId,
    required this.refundPolicy,
    required this.titleStatus,
    required this.descriptionStatus,
    required this.countryStatus,
    required this.refundPolicyStatus,
    required this.metaKeywordsStatus,
    required this.metaDescriptionStatus,
  });

  factory EventLanguageContent.fromJson(Map<String, dynamic> json) {
    return EventLanguageContent(
      id: _asInt(json['id']) ?? 0,
      eventId: _asInt(json['event_id']) ?? 0,
      languageId: _asInt(json['language_id']) ?? 0,
      eventCategoryId: _asInt(json['event_category_id']) ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      metaKeywords: json['meta_keywords'] as String?,
      metaDescription: json['meta_description'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      zipCode: json['zip_code'] as String?,
      googleCalendarId: json['google_calendar_id']?.toString(),
      refundPolicy: json['refund_policy'] as String?,
      titleStatus: json['title_status'] as String?,
      descriptionStatus: json['description_status'] as String?,
      countryStatus: json['country_status'] as String?,
      refundPolicyStatus: json['refund_policy_status'] as String?,
      metaKeywordsStatus: json['meta_keywords_status'] as String?,
      metaDescriptionStatus: json['meta_description_status'] as String?,
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}


