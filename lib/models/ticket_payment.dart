import 'package:day_night/models/purchase/participant.dart';

/// Model to represent a ticket with its price and associated participants for payment processing
class TicketPayment {
  final String ticketId;
  final double ticketPrice;
  final List<Participant> participants;

  TicketPayment({
    required this.ticketId,
    required this.ticketPrice,
    required this.participants,
  });

  /// Total amount for this ticket (price * number of participants)
  double get totalAmount => ticketPrice * participants.length;

  /// Number of participants for this ticket
  int get participantCount => participants.length;

  /// Creates a copy of this ticket payment
  TicketPayment copy() {
    return TicketPayment(
      ticketId: ticketId,
      ticketPrice: ticketPrice,
      participants: List<Participant>.from(participants),
    );
  }

  @override
  String toString() {
    return 'TicketPayment(ticketId: $ticketId, price: $ticketPrice, participants: ${participants.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TicketPayment &&
        other.ticketId == ticketId &&
        other.ticketPrice == ticketPrice;
  }

  @override
  int get hashCode {
    return ticketId.hashCode ^ ticketPrice.hashCode;
  }
}