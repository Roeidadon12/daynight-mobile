import 'package:day_night/constants.dart';
import 'package:day_night/controllers/checkout/ticket/ticket_item.dart';
import 'package:day_night/models/event_details.dart';
import 'package:flutter/material.dart';

class ListTickets extends StatefulWidget {
  final EventDetails eventDetails;
  final List<Ticket> tickets;
  final Function(Ticket?) onTicketSelected;

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
  Ticket? selectedTicket;

  void _selectTicket(Ticket ticket) {
    setState(() {
      // If the same ticket is tapped again, deselect it
      selectedTicket = selectedTicket == ticket ? null : ticket;
      widget.onTicketSelected(selectedTicket);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.tickets.map((ticket) {
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
                initialAmount: 0,
                isSelected: selectedTicket == ticket,
                onAmountChanged: (newAmount) {
                  // Handle amount change logic here
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
