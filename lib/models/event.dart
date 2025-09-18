import '../utils/functions.dart';

class Ticket {
  final double? price;
  final String? description;
  final int? id;
  final int? eventId;
  final String? eventType;
  final String? title;
  final String? ticketAvailableType;
  final int? ticketAvailable;
  final String? maxTicketBuyType;
  final int? maxBuyTicket;
  final String? pricingType;
  final double? fPrice;
  final String? earlyBirdDiscount;
  final String? earlyBirdDiscountAmount;
  final String? earlyBirdDiscountType;
  final DateTime? earlyBirdDiscountDate;
  final DateTime? earlyBirdDiscountTime;
  final String? variations;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? eventOnSaleDate;
  final String? ticketType;
  final int? allocation;
  final String? eventOffSale;
  final String? rounds;
  final int? increment;
  final int? saleLimit;
  final int? ticketStatus;
  final String? ticketImage;
  final int? requiredGender;
  final int? requiredDob;
  final int? requiredIdNumber;
  final String? zeroSetByAdmin;
  final int? isDeleted;

  Ticket({
    this.id,
    this.eventId,
    this.eventType,
    this.title,
    this.ticketAvailableType,
    this.ticketAvailable,
    this.maxTicketBuyType,
    this.maxBuyTicket,
    this.description,
    this.pricingType,
    this.price,
    this.fPrice,
    this.earlyBirdDiscount,
    this.earlyBirdDiscountAmount,
    this.earlyBirdDiscountType,
    this.earlyBirdDiscountDate,
    this.earlyBirdDiscountTime,
    this.variations,
    this.createdAt,
    this.updatedAt,
    this.eventOnSaleDate,
    this.ticketType,
    this.allocation,
    this.eventOffSale,
    this.rounds,
    this.increment,
    this.saleLimit,
    this.ticketStatus,
    this.ticketImage,
    this.requiredGender,
    this.requiredDob,
    this.requiredIdNumber,
    this.zeroSetByAdmin,
    this.isDeleted,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: getJsonField<int>(json, 'id'),
      title: getJsonField<String>(json, 'title'),
      price: getJsonField<double>(json, 'price', defaultValue: 0.0),
      description: getJsonField<String>(json, 'description'),
      eventId: getJsonField<int>(json, 'event_id'),
      eventType: getJsonField<String>(json, 'event_type'),
      ticketAvailableType: getJsonField<String>(json, 'ticket_available_type'),
      ticketAvailable: getJsonField<int>(json, 'ticket_available'),
      maxTicketBuyType: getJsonField<String>(json, 'max_ticket_buy_ty'),
      maxBuyTicket: getJsonField<int>(json, 'max_buy_ticket'),
      pricingType: getJsonField<String>(json, 'pricing_type'),
      fPrice: getJsonField<double>(json, 'f_price', defaultValue: 0.0),
      earlyBirdDiscount: getJsonField<String>(json, 'early_bird_discount'),
      earlyBirdDiscountAmount: getJsonField<String>(json, 'early_bird_discount_amount'),
      earlyBirdDiscountType: getJsonField<String>(json, 'early_bird_discount_type'),
      earlyBirdDiscountDate: getJsonField<DateTime>(json, 'early_bird_discount_date'),
      earlyBirdDiscountTime: getJsonField<DateTime>(json, 'early_bird_discount_time'),
      variations: getJsonField<String>(json, 'variations'),
      createdAt: getJsonField<DateTime>(json, 'created_at'),
      updatedAt: getJsonField<DateTime>(json, 'updated_at'),
      eventOnSaleDate: getJsonField<DateTime>(json, 'event_on_sale_date'),
      ticketType: getJsonField<String>(json, 'ticket_type'),
      allocation: getJsonField<int>(json, 'allocation'),
      eventOffSale: getJsonField<String>(json, 'event_off_sale'),
      rounds: getJsonField<String>(json, 'rounds'),
      increment: getJsonField<int>(json, 'increment'),
      saleLimit: getJsonField<int>(json, 'sale_limit'),
      ticketStatus: getJsonField<int>(json, 'ticket_status'),
      ticketImage: getJsonField<String>(json, 'ticket_image'),
      requiredGender: getJsonField<int>(json, 'required_gender'),
      requiredDob: getJsonField<int>(json, 'required_dob'),
      requiredIdNumber: getJsonField<int>(json, 'required_id_number'),
      zeroSetByAdmin: getJsonField<String>(json, 'zero_set_by_admin'),
      isDeleted: getJsonField<int>(json, 'is_deleted', defaultValue: 0),
    );
  }
}
/*
class Event {
  final int? id;
  final int? organizerId;
  final String? thumbnail;
  final String? status;
  final String? dateType;
  final int? countdownStatus;
  final String? startDate;
  final String? startTime;
  final String? duration;
  final String? endDate;
  final String? endTime;
  final String? endDateTime;
  final double? price;

  String get formattedStartDate {
    if (startDate == null) return '';
    try {
      final date = DateTime.parse(startDate!);
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return startDate!;
    }
  }

  final String? createdAt;
  final String? updatedAt;
  final String? eventType;
  final String? isFeatured;
  final double? latitude;
  final double? longitude;
  final int? minAge;
  final int? isRequiredIdNumber;
  final int? isRequiredFacebookUsername;
  final int? isRequiredInstagramUsername;
  final String? coverImage;
  final int? mapStatus;
  final String? mapAddress;
  final int? isRequiredFacebookOrInstagram;
  final int? autoTicketApproval;
  final int? taxStatus;
  final String? taxType;
  final double? taxAmount;
  final int? imageOfIdStatus;
  final int? measurementId;
  final int? pixelId;
  final int? tiktokPixelId;
  final List<Ticket>? tickets;
  final Map<String, dynamic>? information;
  final List<dynamic>? booking;
  final List<dynamic>? wishlists;
  final dynamic organizer;
  final List<dynamic>? galleries;
  final List<dynamic>? dates;
  final List<dynamic>? visitors;

  Event({
    this.id,
    this.organizerId,
    this.thumbnail,
    this.status,
    this.dateType,
    this.countdownStatus,
    this.startDate,
    this.startTime,
    this.duration,
    this.endDate,
    this.endTime,
    this.endDateTime,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.eventType,
    this.isFeatured,
    this.latitude,
    this.longitude,
    this.minAge,
    this.isRequiredIdNumber,
    this.isRequiredFacebookUsername,
    this.isRequiredInstagramUsername,
    this.coverImage,
    this.mapStatus,
    this.mapAddress,
    this.isRequiredFacebookOrInstagram,
    this.autoTicketApproval,
    this.taxStatus,
    this.taxType,
    this.taxAmount,
    this.imageOfIdStatus,
    this.measurementId,
    this.pixelId,
    this.tiktokPixelId,
    this.tickets,
    this.information,
    this.booking,
    this.wishlists,
    this.organizer,
    this.galleries,
    this.dates,
    this.visitors,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: getJsonField<int>(json, 'id'),
      organizerId: getJsonField<int>(json, 'organizer_id'),
      thumbnail: getJsonField<String>(json, 'thumbnail'),
      status: getJsonField<String>(json, 'status'),
      dateType: getJsonField<String>(json, 'date_type'),
      countdownStatus: getJsonField<int>(json, 'countdown_status'),
      startDate: getJsonField<String>(json, 'start_date'),
      startTime: getJsonField<String>(json, 'start_time'),
      duration: getJsonField<String>(json, 'duration'),
      endDate: getJsonField<String>(json, 'end_date'),
      endTime: getJsonField<String>(json, 'end_time'),
      endDateTime: getJsonField<String>(json, 'end_date_time'),
      price: getJsonField<double>(json, 'price', defaultValue: 0.0),
      createdAt: getJsonField<String>(json, 'created_at'),
      updatedAt: getJsonField<String>(json, 'updated_at'),
      eventType: getJsonField<String>(json, 'event_type'),
      isFeatured: getJsonField<String>(json, 'is_featured'),
      latitude: getJsonField<double>(json, 'latitude'),
      longitude: getJsonField<double>(json, 'longitude'),
      minAge: getJsonField<int>(json, 'min_age'),
      isRequiredIdNumber: getJsonField<int>(json, 'is_required_id_number'),
      isRequiredFacebookUsername: getJsonField<int>(json, 'is_required_facebook_username'),
      isRequiredInstagramUsername: getJsonField<int>(json, 'is_required_instagram_username'),
      coverImage: getJsonField<String>(json, 'cover_image'),
      mapStatus: getJsonField<int>(json, 'map_status'),
      mapAddress: getJsonField<String>(json, 'map_address'),
      isRequiredFacebookOrInstagram: getJsonField<int>(json, 'is_required_facebook_or_instagram'),
      autoTicketApproval: getJsonField<int>(json, 'auto_ticket_approval'),
      taxStatus: getJsonField<int>(json, 'tax_status'),
      taxType: getJsonField<String>(json, 'tax_type'),
      taxAmount: getJsonField<double>(json, 'tax_amount'),
      imageOfIdStatus: getJsonField<int>(json, 'image_of_id_status'),
      measurementId: getJsonField<int>(json, 'measurement_id'),
      pixelId: getJsonField<int>(json, 'pixel_id'),
      tiktokPixelId: getJsonField<int>(json, 'tiktok_pixel_id'),
      tickets: (getJsonField<List<dynamic>>(json, 'tickets'))
          ?.map((item) => Ticket.fromJson(item as Map<String, dynamic>))
          .toList(),
      information: getJsonField<Map<String, dynamic>>(json, 'information'),
      booking: getJsonField<List<dynamic>>(json, 'booking'),
      wishlists: getJsonField<List<dynamic>>(json, 'wishlists'),
      organizer: getJsonField<dynamic>(json, 'organizer'),
      galleries: getJsonField<List<dynamic>>(json, 'galleries'),
      dates: getJsonField<List<dynamic>>(json, 'dates'),
      visitors: getJsonField<List<dynamic>>(json, 'visitors'),
    );
  }

  String? get thumbnailUrl {
    if (thumbnail == null || thumbnail!.isEmpty) return null;
    return 'kCoverImageBaseUrl/$thumbnail'.replaceFirst(
      'kCoverImageBaseUrl',
      kCoverImageBaseUrl,
    );
  }

  String get title {
    return information?['title']?.toString() ?? '';
  }

  String get description {
    return information?['description']?.toString() ?? '';
  }

  String get location {
    final country = information?['country']?.toString() ?? '';
    final city = information?['city']?.toString() ?? '';
    final state = information?['state']?.toString() ?? '';
    final address = information?['address']?.toString() ?? '';

    // Build location string from available fields
    final parts = [
      address,
      city,
      state,
      country,
    ].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  String get startShortDate {
    final rawDate = startDate?.toString();
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final date = DateTime.parse(rawDate);
      // Format: 'MMM d' (e.g., 'Jul 21')
      return DateFormat('MMM d').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  String get eventLocationDateTime {
    return '$startShortDate | $location';
  }
}
*/