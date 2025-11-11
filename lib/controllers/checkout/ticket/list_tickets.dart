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
  // Track selected tickets with their amounts
  final Map<String, int> _ticketAmounts = {};
  String? _selectedTicketId; // allow only one selected row at a time

  void _selectTicket(Ticket ticket) {
    final String id = ticket.id.toString();

    // Prepare previous ticket (if any) to notify about deselection
    Ticket? prevTicket;
    if (_selectedTicketId != null && _selectedTicketId != id) {
      try {
        prevTicket = widget.tickets.firstWhere((t) => t.id.toString() == _selectedTicketId);
      } catch (_) {
        prevTicket = null;
      }
    }

    setState(() {
      if (_selectedTicketId == id) {
        // Toggle selection: if already selected, unselect and set amount to 0
        final newAmount = (_ticketAmounts[id] ?? 0) > 0 ? 0 : 1;
        _ticketAmounts[id] = newAmount;
        _selectedTicketId = newAmount > 0 ? id : null;
        widget.onTicketSelected(newAmount > 0 ? ticket : null, newAmount);
      } else {
        // Select this ticket and clear others
        _selectedTicketId = id;
        // Zero out all other amounts
        _ticketAmounts.updateAll((key, value) => 0);
        // Ensure at least 1 by default when selecting
        final newAmount = (_ticketAmounts[id] ?? 0) > 0 ? _ticketAmounts[id]! : 1;
        _ticketAmounts[id] = newAmount;

        // Notify parent about previous deselection and the new selection
        if (prevTicket != null) {
          widget.onTicketSelected(prevTicket, 0);
        }
        widget.onTicketSelected(ticket, newAmount);
      }
    });
  }

  void _handleAmountChange(Ticket ticket, int newAmount) {
    final String id = ticket.id.toString();

    // Determine if we need to deselect a previously selected ticket
    Ticket? prevTicket;
    if (newAmount > 0 && _selectedTicketId != null && _selectedTicketId != id) {
      try {
        prevTicket = widget.tickets.firstWhere((t) => t.id.toString() == _selectedTicketId);
      } catch (_) {
        prevTicket = null;
      }
    }

    setState(() {
      if (newAmount > 0) {
        // Selecting/adjusting this ticket => make it the only selected one
        _selectedTicketId = id;
        _ticketAmounts.updateAll((key, value) => 0);
      } else {
        // Amount became 0 -> if it was the selected one, clear selection
        if (_selectedTicketId == id) {
          _selectedTicketId = null;
        }
      }

      _ticketAmounts[id] = newAmount;
    });

    // Notify parent: first clear previous selection (if any), then update this one
    if (prevTicket != null) {
      widget.onTicketSelected(prevTicket, 0);
    }
    widget.onTicketSelected(ticket, newAmount);
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
                initialAmount: _ticketAmounts[ticket.id.toString()] ?? 0,
                isSelected: _selectedTicketId == ticket.id.toString(),
                onAmountChanged: (newAmount) => _handleAmountChange(ticket, newAmount),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
