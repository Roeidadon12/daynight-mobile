import 'package:intl/intl.dart';

/// A model representing a ticket for an event in the DayNight application.
///
/// This class contains all the information related to a ticket, including pricing,
/// availability, and purchase restrictions.
class Ticket {
  /// The price of the ticket in the default currency.
  final double? price;

  /// Detailed description of what the ticket includes or any special conditions.
  final String? description;

  /// Unique identifier for the ticket.
  final int? id;

  /// Reference to the associated event.
  final int? eventId;

  /// The type of event this ticket is for (e.g., 'concert', 'theater', etc.).
  final String? eventType;

  /// The display name of the ticket.
  final String? title;

  /// Defines how ticket availability is managed ('fixed', 'unlimited', etc.).
  final String? ticketAvailableType;

  /// The number of tickets available for purchase.
  final int? ticketAvailable;

  /// Defines how maximum ticket purchases are restricted.
  final String? maxTicketBuyType;

  /// Maximum number of tickets that can be purchased in a single transaction.
  final int? maxBuyTicket;

  /// The type of pricing strategy used ('fixed', 'variable', etc.).
  final String? pricingType;

  /// The fixed price of the ticket (if applicable).
  final double? fPrice;

  /// Indicates if early bird discount is available.
  final String? earlyBirdDiscount;

  /// The amount of early bird discount.
  final String? earlyBirdDiscountAmount;

  /// The type of early bird discount ('percentage', 'fixed', etc.).
  final String? earlyBirdDiscountType;

  /// The date until which early bird discount is valid.
  final DateTime? earlyBirdDiscountDate;

  /// The time at which early bird discount expires.
  final DateTime? earlyBirdDiscountTime;

  /// JSON string containing ticket variations (if any).
  final String? variations;

  /// When the ticket was created.
  final DateTime? createdAt;

  /// When the ticket was last updated.
  final DateTime? updatedAt;

  /// When the ticket goes on sale.
  final DateTime? eventOnSaleDate;

  /// The category or type of the ticket.
  final String? ticketType;

  /// Total number of tickets allocated.
  final int? allocation;

  /// When ticket sales end.
  final String? eventOffSale;

  /// Available purchase rounds for the ticket.
  final String? rounds;

  /// Increment value for ticket purchases.
  final int? increment;

  /// Maximum limit for ticket sales.
  final int? saleLimit;

  /// Current status of the ticket (e.g., 1 for active, 0 for inactive).
  final int? ticketStatus;

  /// URL or path to the ticket's image.
  final String? ticketImage;

  /// Whether gender information is required (1 for yes, 0 for no).
  final int? requiredGender;

  /// Whether date of birth is required (1 for yes, 0 for no).
  final int? requiredDob;

  /// Whether ID number is required (1 for yes, 0 for no).
  final int? requiredIdNumber;

  /// Administrative setting for zero quantity.
  final String? zeroSetByAdmin;

  /// Soft delete flag (1 for deleted, 0 for active).
  final int? isDeleted;

  /// Creates a new [Ticket] instance.
  ///
  /// All parameters are optional and can be null.
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
    this.price,
    this.pricingType,
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

  /// Creates a [Ticket] instance from a JSON map.
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int?,
      eventId: json['event_id'] as int?,
      eventType: json['event_type'] as String?,
      title: json['title'] as String?,
      ticketAvailableType: json['ticket_available_type'] as String?,
      ticketAvailable: json['ticket_available'] as int?,
      maxTicketBuyType: json['max_ticket_buy_type'] as String?,
      maxBuyTicket: json['max_buy_ticket'] as int?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      pricingType: json['pricing_type'] as String?,
      fPrice: (json['f_price'] as num?)?.toDouble(),
      earlyBirdDiscount: json['early_bird_discount'] as String?,
      earlyBirdDiscountAmount: json['early_bird_discount_amount'] as String?,
      earlyBirdDiscountType: json['early_bird_discount_type'] as String?,
      earlyBirdDiscountDate: json['early_bird_discount_date'] != null
          ? DateTime.parse(json['early_bird_discount_date'])
          : null,
      earlyBirdDiscountTime: json['early_bird_discount_time'] != null
          ? DateTime.parse(json['early_bird_discount_time'])
          : null,
      variations: json['variations'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      eventOnSaleDate: json['event_on_sale_date'] != null
          ? DateTime.parse(json['event_on_sale_date'])
          : null,
      ticketType: json['ticket_type'] as String?,
      allocation: json['allocation'] as int?,
      eventOffSale: json['event_off_sale'] as String?,
      rounds: json['rounds'] as String?,
      increment: json['increment'] as int?,
      saleLimit: json['sale_limit'] as int?,
      ticketStatus: json['ticket_status'] as int?,
      ticketImage: json['ticket_image'] as String?,
      requiredGender: json['required_gender'] as int?,
      requiredDob: json['required_dob'] as int?,
      requiredIdNumber: json['required_id_number'] as int?,
      zeroSetByAdmin: json['zero_set_by_admin'] as String?,
      isDeleted: json['is_deleted'] as int?,
    );
  }

  /// Converts the ticket instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'event_type': eventType,
      'title': title,
      'ticket_available_type': ticketAvailableType,
      'ticket_available': ticketAvailable,
      'max_ticket_buy_type': maxTicketBuyType,
      'max_buy_ticket': maxBuyTicket,
      'description': description,
      'price': price,
      'pricing_type': pricingType,
      'f_price': fPrice,
      'early_bird_discount': earlyBirdDiscount,
      'early_bird_discount_amount': earlyBirdDiscountAmount,
      'early_bird_discount_type': earlyBirdDiscountType,
      'early_bird_discount_date': earlyBirdDiscountDate?.toIso8601String(),
      'early_bird_discount_time': earlyBirdDiscountTime?.toIso8601String(),
      'variations': variations,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'event_on_sale_date': eventOnSaleDate?.toIso8601String(),
      'ticket_type': ticketType,
      'allocation': allocation,
      'event_off_sale': eventOffSale,
      'rounds': rounds,
      'increment': increment,
      'sale_limit': saleLimit,
      'ticket_status': ticketStatus,
      'ticket_image': ticketImage,
      'required_gender': requiredGender,
      'required_dob': requiredDob,
      'required_id_number': requiredIdNumber,
      'zero_set_by_admin': zeroSetByAdmin,
      'is_deleted': isDeleted,
    };
  }
}
