import '../../constants.dart';
import 'package:intl/intl.dart';

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
  final List<dynamic>? tickets;
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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      organizerId: json['organizer_id'] is int ? json['organizer_id'] : int.tryParse(json['organizer_id']?.toString() ?? ''),
      thumbnail: json['thumbnail'],
      status: json['status'],
      dateType: json['date_type'],
      countdownStatus: json['countdown_status'] is int ? json['countdown_status'] : int.tryParse(json['countdown_status']?.toString() ?? ''),
      startDate: json['start_date'],
      startTime: json['start_time'],
      duration: json['duration'],
      endDate: json['end_date'],
      endTime: json['end_time'],
      endDateTime: json['end_date_time'],
      price: json['price'] is double ? json['price'] : double.tryParse(json['price']?.toString() ?? '0'),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      eventType: json['event_type'],
      isFeatured: json['is_featured'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      minAge: json['min_age'] is int ? json['min_age'] : int.tryParse(json['min_age']?.toString() ?? ''),
      isRequiredIdNumber: json['is_required_id_number'],
      isRequiredFacebookUsername: json['is_required_facebook_username'] is int ? json['is_required_facebook_username'] : int.tryParse(json['is_required_facebook_username']?.toString() ?? ''),
      isRequiredInstagramUsername: json['is_required_instagram_username'] is int ? json['is_required_instagram_username'] : int.tryParse(json['is_required_instagram_username']?.toString() ?? ''),
      coverImage: json['cover_image'],
      mapStatus: json['map_status'] is int ? json['map_status'] : int.tryParse(json['map_status']?.toString() ?? ''),
      mapAddress: json['map_address'],
      isRequiredFacebookOrInstagram: json['is_required_facebook_or_instagram'] is int ? json['is_required_facebook_or_instagram'] : int.tryParse(json['is_required_facebook_or_instagram']?.toString() ?? ''),
      autoTicketApproval: json['auto_ticket_approval'] is int ? json['auto_ticket_approval'] : int.tryParse(json['auto_ticket_approval']?.toString() ?? ''),
      taxStatus: json['tax_status'] is int ? json['tax_status'] : int.tryParse(json['tax_status']?.toString() ?? ''),
      taxType: json['tax_type'],
      taxAmount: json['tax_amount'] != null ? double.tryParse(json['tax_amount'].toString()) : null,
      imageOfIdStatus: json['image_of_id_status'] is int ? json['image_of_id_status'] : int.tryParse(json['image_of_id_status']?.toString() ?? ''),
      measurementId: json['measurement_id'] is int ? json['measurement_id'] : int.tryParse(json['measurement_id']?.toString() ?? ''),
      pixelId: json['pixel_id'] is int ? json['pixel_id'] : int.tryParse(json['pixel_id']?.toString() ?? ''),
      tiktokPixelId: json['tiktok_pixel_id'] is int ? json['tiktok_pixel_id'] : int.tryParse(json['tiktok_pixel_id']?.toString() ?? ''),
      tickets: json['tickets'] as List<dynamic>?,
      information: json['information'] as Map<String, dynamic>?,
      booking: json['booking'] as List<dynamic>?,
      wishlists: json['wishlists'] as List<dynamic>?,
      organizer: json['organizer'],
      galleries: json['galleries'] as List<dynamic>?,
      dates: json['dates'] as List<dynamic>?,
      visitors: json['visitors'] as List<dynamic>?,
    );
  }

  String? get thumbnailUrl {
    if (thumbnail == null || thumbnail!.isEmpty) return null;
    return 'kCoverImageBaseUrl/$thumbnail'.replaceFirst('kCoverImageBaseUrl', kCoverImageBaseUrl);
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
    final parts = [address, city, state, country].where((part) => part.isNotEmpty).toList();
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
