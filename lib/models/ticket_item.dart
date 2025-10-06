import 'ticket.dart';

class TicketItem {
  final String id;
  final Ticket ticket;
  int quantity;

  TicketItem({
    required this.id,
    required this.ticket,
    required this.quantity,
  });

  double get price {
    if (ticket.pricingType == 'rounds' && ticket.activeRound != null) {
      return ticket.activeRound!.price;
    }
    return ticket.price != null ? double.tryParse(ticket.price!) ?? 0.0 : 0.0;
  }

  String get name => ticket.title;
}