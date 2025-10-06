class Round {
  final String uniqueId;
  final double price;
  final int allocation;
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
      price: _parsePrice(json['price']),
      allocation: _parseAllocation(json['allocation']),
      eventOffSale: json['event_off_sale'],
      zeroSetByAdmin: json['zero_set_by_admin'],
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static int _parseAllocation(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  // Helper method to display price as whole number
  int get priceAsInt => price.round();
}

class Ticket {
  final int id;
  final String pricingType;
  final int increment;
  final int saleLimit;
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
      saleLimit: _parseSaleLimit(json['sale_limit']),
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

  static int _parseSaleLimit(dynamic value) {
    if (value == null) return 999;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 999;
    }
    return 999;
  }
}