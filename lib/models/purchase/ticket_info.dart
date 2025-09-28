import '../ticket_item.dart';

class TicketInfo {
  final List<TicketItem> tickets;
  final double totalPrice;
  final int totalQuantity;

  TicketInfo({
    required this.tickets,
  }) : totalPrice = tickets.fold(0.0, (sum, ticket) => sum + (ticket.price * ticket.quantity)),
       totalQuantity = tickets.fold(0, (sum, ticket) => sum + ticket.quantity);

  bool get isEmpty => tickets.isEmpty;
  bool get isNotEmpty => tickets.isNotEmpty;
}