import 'package:day_night/constants.dart';
import 'package:day_night/controllers/checkout/ticket/ticket_item.dart';
import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/ticket.dart';
import 'package:flutter/material.dart';

class ListTickets extends StatefulWidget {
  final EventDetails eventDetails;
  final List<Ticket> tickets;
  final Function(Ticket?, int) onTicketSelected;

  const ListTickets({
    super.key, 
    required this.eventDetails,
    required this.tickets,
    required this.onTicketSelected,
  });

  @override
  ListTicketsState createState() => ListTicketsState();
}

class ListTicketsState extends State<ListTickets> {
  // Track selected tickets with their amounts - support multiple selections
  final Map<String, int> _ticketAmounts = {};

  void _selectTicket(Ticket ticket) {
    final String id = ticket.id.toString();

    setState(() {
      // Toggle selection: if already selected with amount > 0, set to 0, otherwise set to 1
      final currentAmount = _ticketAmounts[id] ?? 0;
      final newAmount = currentAmount > 0 ? 0 : 1;
      _ticketAmounts[id] = newAmount;
      widget.onTicketSelected(ticket, newAmount);
    });
  }

  void _handleAmountChange(Ticket ticket, int newAmount) {
    final String id = ticket.id.toString();

    setState(() {
      _ticketAmounts[id] = newAmount;
    });

    widget.onTicketSelected(ticket, newAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.tickets.map((ticket) {
        final ticketId = ticket.id.toString();
        final isSelected = (_ticketAmounts[ticketId] ?? 0) > 0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () => _selectTicket(ticket),
            child: Container(
              decoration: BoxDecoration(
                color: kMainBackgroundColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TicketItem(
                eventDetails: widget.eventDetails,
                ticket: ticket,
                initialAmount: _ticketAmounts[ticketId] ?? 0,
                isSelected: isSelected,
                onAmountChanged: (newAmount) => _handleAmountChange(ticket, newAmount),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
