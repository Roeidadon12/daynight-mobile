import 'package:day_night/controllers/checkout/participant/participant_info.dart';

import '../ticket_item.dart';
import 'personal_info.dart';
import 'ticket_info.dart';

class PurchaseBasket {
  TicketInfo? _ticketInfo;
  PersonalInfo? _personalInfo;
  late ParticipantInfo _participantsInfo;

  /// Adds tickets to the basket
  void addTickets(List<TicketItem> tickets) {
    _ticketInfo = TicketInfo(tickets: tickets);
  }

  /// Updates the purchaser's information
  void setPurchaserInfo({
    required String fullName,
    required String email,
    required String phone,
    String? idNumber,
  }) {
    _personalInfo = PersonalInfo(
      fullName: fullName,
      email: email,
      phone: phone,
      idNumber: idNumber,
    );
  }

  void setParticipantsInfo(ParticipantInfo info) {
    _participantsInfo = info;
  }

  /// Gets the current ticket information
  TicketInfo? get ticketInfo => _ticketInfo;

  /// Gets the purchaser's information
  PersonalInfo? get purchaserInfo => _personalInfo;

  ParticipantInfo get participantsInfo => _participantsInfo;

  /// Gets the list of participants
  /// 
  /// Gets the total price of the purchase
  double get totalPrice => _ticketInfo?.totalPrice ?? 0.0;

  /// Gets the total number of tickets in the basket
  int get totalQuantity => _ticketInfo?.totalQuantity ?? 0;

  /// Checks if the basket has all required information
  bool isValid() {
    if (_ticketInfo == null || _ticketInfo!.isEmpty) return false;
    if (_personalInfo == null) return false;
    if (participantsInfo.participants.length != _ticketInfo!.totalQuantity - 1) return false;
    return true;
  }

  /// Clears all data from the basket
  void clear() {
    _ticketInfo = null;
    _personalInfo = null;
    _participantsInfo.participants.clear();
  }
}