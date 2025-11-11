import '../ticket_item.dart';
import 'dart:io';

/// Payment service request object containing all data required for payment processing
class PaymentServiceRequest {
  // Event Information
  final int eventId;
  final double total;
  
  // Processing Fees
  final String? processingFeeType; // 'fixed' or 'percentage'
  final double? processingFee;
  final double? processingFeePercentage;
  
  // Discount and Coupon
  final double? discount;
  final int? couponId;
  
  // Ticket Information
  final int quantity;
  final List<SellTicket> sellTickets;
  
  // Participant Information as Maps (participant index -> value)
  final Map<String, String> fname;
  final Map<String, String> lname;
  final Map<String, String> gender;
  final Map<String, String> dateOfBirth;
  final Map<String, String> countryCode;
  final Map<String, String> phone;
  final Map<String, String> email;
  final Map<String, String?> idNumber;
  final Map<String, String?> instagramUsername;
  final Map<String, String?> facebookUsername;
  
  // Image files for ID verification
  final Map<String, File?> imageOfId;

  const PaymentServiceRequest({
    required this.eventId,
    required this.total,
    this.processingFeeType,
    this.processingFee,
    this.processingFeePercentage,
    this.discount,
    this.couponId,
    required this.quantity,
    required this.sellTickets,
    required this.fname,
    required this.lname,
    required this.gender,
    required this.dateOfBirth,
    required this.countryCode,
    required this.phone,
    required this.email,
    required this.idNumber,
    required this.instagramUsername,
    required this.facebookUsername,
    required this.imageOfId,
  });

  /// Converts the payment request to a form data map for API calls
  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> formData = {
      'event_id': eventId.toString(),
      'total': total.toString(),
      'quantity': quantity.toString(),
    };

    // Add sell_tickets as JSON string
    formData['sell_tickets'] = _sellTicketsToJsonString();

    // Add participant data as JSON strings
    formData['fname'] = _mapToJsonString(fname);
    formData['lname'] = _mapToJsonString(lname);
    formData['gender'] = _mapToJsonString(gender);
    formData['date_of_birth'] = _mapToJsonString(dateOfBirth);
    formData['country_code'] = _mapToJsonString(countryCode);
    formData['phone'] = _mapToJsonString(phone);
    formData['email'] = _mapToJsonString(email);
    formData['id_number'] = _mapToJsonString(idNumber);
    formData['instagram_username'] = _mapToJsonString(instagramUsername);
    formData['facebook_username'] = _mapToJsonString(facebookUsername);

    // Add optional fields only if they're not null
    if (processingFeeType != null) {
      formData['prcessing_fee_type'] = processingFeeType;
    }
    if (processingFee != null) {
      formData['processing_fee'] = processingFee.toString();
    }
    if (processingFeePercentage != null) {
      formData['prcessing_fee_percentage'] = processingFeePercentage.toString();
    }
    if (discount != null) {
      formData['discount'] = discount.toString();
    }
    if (couponId != null) {
      formData['coupon_id'] = couponId.toString();
    }

    return formData;
  }

  /// Converts sell tickets to JSON string format
  String _sellTicketsToJsonString() {
    final List<Map<String, dynamic>> ticketsJson = sellTickets.map((ticket) => ticket.toJson()).toList();
    return ticketsJson.toString().replaceAll('\'', '"');
  }

  /// Converts a map to JSON string format
  String _mapToJsonString(Map<String, dynamic> map) {
    return map.toString().replaceAll('\'', '"');
  }

  /// Gets the image files for multipart upload
  Map<String, File?> getImageFiles() => imageOfId;

  /// Backward compatibility method - alias for toFormData()
  Map<String, dynamic> toJson() => toFormData();

  /// Creates a PaymentServiceRequest from existing app models
  factory PaymentServiceRequest.fromAppModels({
    required int eventId,
    required List<TicketItem> tickets,
    required String purchaserFullName,
    required String purchaserEmail,
    required String purchaserPhone,
    required String purchaserCountryCode,
    required List<ParticipantPaymentInfo> participants,
    String? purchaserIdNumber,
    String? purchaserInstagram,
    String? purchaserFacebook,
    String? purchaserGender,
    String? purchaserDateOfBirth,
    File? purchaserIdImage,
    // Optional override for first/last name if you want to specify them directly
    String? purchaserFirstName,
    String? purchaserLastName,
    double? processingFee,
    String? processingFeeType,
    double? processingFeePercentage,
    double? discount,
    int? couponId,
  }) {
    // Calculate total quantity and price
    final quantity = tickets.fold(0, (sum, ticket) => sum + ticket.quantity);
    final total = tickets.fold(0.0, (sum, ticket) => sum + (ticket.price * ticket.quantity));
    
    // Create sell tickets array
    final sellTickets = tickets.map((ticket) => SellTicket(
      ticketId: ticket.id,
      quantity: ticket.quantity.toString(),
      price: ticket.price.toString(),
      name: ticket.name,
      requiredGender: ticket.ticket.requiredGender,
      requiredDob: ticket.ticket.requiredDob,
      requiredIdNumber: ticket.ticket.requiredIdNumber,
      uniqueId: ticket.ticket.activeRound?.uniqueId, // Use round unique ID if available
    )).toList();

    // Initialize maps with purchaser info first (index "1")
    // Use provided first/last names if available, otherwise extract from full name
    final fname = <String, String>{'1': purchaserFirstName ?? _extractFirstName(purchaserFullName)};
    final lname = <String, String>{'1': purchaserLastName ?? _extractLastName(purchaserFullName)};
    final gender = <String, String>{'1': purchaserGender ?? ''};
    final dateOfBirth = <String, String>{'1': purchaserDateOfBirth ?? ''};
    final countryCode = <String, String>{'1': purchaserCountryCode};
    final phone = <String, String>{'1': purchaserPhone};
    final email = <String, String>{'1': purchaserEmail};
    final idNumber = <String, String?>{'1': purchaserIdNumber};
    final instagramUsername = <String, String?>{'1': purchaserInstagram};
    final facebookUsername = <String, String?>{'1': purchaserFacebook};
    final imageOfId = <String, File?>{'1': purchaserIdImage};

    // Add participant information (starting from index "2")
    for (int i = 0; i < participants.length; i++) {
      final participant = participants[i];
      final index = (i + 2).toString(); // Start from "2" since purchaser is "1"
      
      fname[index] = participant.firstName;
      lname[index] = participant.lastName;
      gender[index] = participant.gender ?? '';
      dateOfBirth[index] = participant.dateOfBirth ?? '';
      countryCode[index] = participant.countryCode;
      phone[index] = participant.phone;
      email[index] = participant.email;
      idNumber[index] = participant.idNumber;
      instagramUsername[index] = participant.instagramUsername;
      facebookUsername[index] = participant.facebookUsername;
      imageOfId[index] = participant.idImage;
    }

    return PaymentServiceRequest(
      eventId: eventId,
      total: total,
      processingFeeType: processingFeeType,
      processingFee: processingFee,
      processingFeePercentage: processingFeePercentage,
      discount: discount,
      couponId: couponId,
      quantity: quantity,
      sellTickets: sellTickets,
      fname: fname,
      lname: lname,
      gender: gender,
      dateOfBirth: dateOfBirth,
      countryCode: countryCode,
      phone: phone,
      email: email,
      idNumber: idNumber,
      instagramUsername: instagramUsername,
      facebookUsername: facebookUsername,
      imageOfId: imageOfId,
    );
  }

  /// Helper method to extract first name from full name
  static String _extractFirstName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  /// Helper method to extract last name from full name
  static String _extractLastName(String fullName) {
    final parts = fullName.trim().split(' ');
    return parts.length > 1 ? parts.skip(1).join(' ') : '';
  }
}

/// Represents a ticket being sold in the payment request
class SellTicket {
  final String? uniqueId;
  final String ticketId;
  final String name;
  final String price;
  final String quantity; // Changed to String to match API format
  final int? requiredGender;
  final int? requiredDob;
  final int? requiredIdNumber;

  const SellTicket({
    this.uniqueId,
    required this.ticketId,
    required this.name,
    required this.price,
    required this.quantity,
    this.requiredGender,
    this.requiredDob,
    this.requiredIdNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'unique_id': uniqueId,
      'ticket_id': ticketId,
      'name': name,
      'price': price,
      'qty': quantity,
      'required_gender': requiredGender,
      'required_dob': requiredDob,
      'required_id_number': requiredIdNumber,
    };
  }
}

/// Represents participant information for payment processing
class ParticipantPaymentInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String countryCode;
  final String? gender;
  final String? dateOfBirth;
  final String? idNumber;
  final String? instagramUsername;
  final String? facebookUsername;
  final File? idImage;

  const ParticipantPaymentInfo({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.countryCode,
    this.gender,
    this.dateOfBirth,
    this.idNumber,
    this.instagramUsername,
    this.facebookUsername,
    this.idImage,
  });
}