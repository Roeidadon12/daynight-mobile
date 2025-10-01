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
      return double.parse(ticket.activeRound!.price);
    }
    return double.parse(ticket.price ?? '0');
  }

  String get name => ticket.title;
}