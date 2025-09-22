class EventDetails {
  final String status;
  final EventInformation eventInformation;
  final String organizer;
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
      organizer: json['organizer'] ?? '',
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

class RelatedEvent {
  final int id;
  final String thumbnail;
  final String title;
  final String description;
  final String? city;
  final String country;

  RelatedEvent({
    required this.id,
    required this.thumbnail,
    required this.title,
    required this.description,
    this.city,
    required this.country,
  });

  factory RelatedEvent.fromJson(Map<String, dynamic> json) {
    return RelatedEvent(
      id: json['id'],
      thumbnail: json['thumbnail'],
      title: json['title'],
      description: json['description'],
      city: json['city'],
      country: json['country'],
    );
  }
}

class Round {
  final String uniqueId;
  final String price;
  final String allocation;
  final String eventOffSale;
  final String zeroSetByAdmin;

  Round({
    required this.uniqueId,
    required this.price,
    required this.allocation,
    required this.eventOffSale,
    required this.zeroSetByAdmin,
  });

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      uniqueId: json['unique_id'],
      price: json['price'],
      allocation: json['allocation'],
      eventOffSale: json['event_off_sale'],
      zeroSetByAdmin: json['zero_set_by_admin'],
    );
  }
}

class Ticket {
  final int id;
  final String pricingType;
  final int increment;
  final String saleLimit;
  final int requiredGender;
  final int requiredDob;
  final int requiredIdNumber;
  final int status;
  final String? price;
  final String? image;
  final bool comingSoon;
  final bool soldOut;
  final bool available;
  final String title;
  final String? description;
  final List<Round>? rounds;
  final Round? activeRound;

  Ticket({
    required this.id,
    required this.pricingType,
    required this.increment,
    required this.saleLimit,
    required this.requiredGender,
    required this.requiredDob,
    required this.requiredIdNumber,
    required this.status,
    this.price,
    this.image,
    required this.comingSoon,
    required this.soldOut,
    required this.available,
    required this.title,
    this.description,
    this.rounds,
    this.activeRound,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      pricingType: json['pricing_type'],
      increment: json['increment'],
      saleLimit: json['sale_limit'],
      requiredGender: json['required_gender'],
      requiredDob: json['required_dob'],
      requiredIdNumber: json['required_id_number'],
      status: json['status'],
      price: json['price'],
      image: json['image'],
      comingSoon: json['coming_soon'],
      soldOut: json['sold_out'],
      available: json['available'],
      title: json['title'],
      description: json['description'],
      rounds: json['rounds'] != null
          ? (json['rounds'] as List).map((r) => Round.fromJson(r)).toList()
          : null,
      activeRound: json['active_round'] != null
          ? Round.fromJson(json['active_round'])
          : null,
    );
  }
}
