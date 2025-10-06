import 'ticket.dart';
import 'related_event.dart';
import 'organizer.dart';

class EventDetails {
  final String status;
  final EventInformation eventInformation;
  final Organizer organizer;
  final List<RelatedEvent> relatedEvents;
  final List<Ticket> tickets;

  EventDetails({
    required this.status,
    required this.eventInformation,
    required this.organizer,
    required this.relatedEvents,
    required this.tickets,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      status: json['status'],
      eventInformation: EventInformation.fromJson(json['event_information']),
      organizer: Organizer.fromJson(json['organizer']),
      relatedEvents: (json['related_events'] as List)
          .map((event) => RelatedEvent.fromJson(event))
          .toList(),
      tickets: (json['tickets'] as List)
          .map((ticket) => Ticket.fromJson(ticket))
          .toList(),
    );
  }
}

class EventInformation {
  final int id;
  final String title;
  final String description;
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
      isRequiredIdNumber: json['is_required_id_number'],
      isRequiredFacebookUsername: json['is_required_facebook_username'],
      isRequiredInstagramUsername: json['is_required_instagram_username'],
      isRequiredFacebookOrInstagram: json['is_required_facebook_or_instagram'],
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
