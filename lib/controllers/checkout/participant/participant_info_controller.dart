import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/purchase/participant_info.dart';
import 'package:day_night/models/purchase/personal_info.dart';
import 'package:day_night/models/ticket_item.dart';

class ParticipantInfoController {
  final List<TicketItem> selectedTickets;
  final EventDetails eventDetails;
  PersonalInfo? purchaserInfo;
  final List<ParticipantInfo> participants = [];

  ParticipantInfoController({
    required this.selectedTickets,
    required this.eventDetails,
  });

  int get totalParticipants {
    return selectedTickets.fold(0, (sum, ticket) => sum + ticket.quantity);
  }

  int get remainingParticipants {
    // Subtract 1 from total as the purchaser counts as one participant
    return totalParticipants - (participants.length + 1);
  }

  bool get needsParticipantInfo {
    return selectedTickets.any((ticket) => 
      ticket.ticket.requiredIdNumber == 1 || 
      ticket.ticket.requiredGender == 1 || 
      ticket.ticket.requiredDob == 1
    );
  }

  void setPurchaserInfo({
    required String fullName,
    required String email,
    required String phone,
    String? idNumber,
  }) {
    purchaserInfo = PersonalInfo(
      fullName: fullName,
      email: email,
      phone: phone,
      idNumber: idNumber,
    );
  }

  void addParticipant({
    required String fullName,
    String? idNumber,
  }) {
    if (participants.length < totalParticipants - 1) {
      participants.add(
        ParticipantInfo(
          fullName: fullName,
          idNumber: idNumber,
        ),
      );
    }
  }

  void removeParticipant(int index) {
    if (index >= 0 && index < participants.length) {
      participants.removeAt(index);
    }
  }

  bool isValid() {
    if (purchaserInfo == null) return false;
    if (needsParticipantInfo && remainingParticipants > 0) return false;
    return true;
  }

  void clear() {
    purchaserInfo = null;
    participants.clear();
  }
}