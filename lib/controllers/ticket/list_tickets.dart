import 'package:day_night/controllers/ticket/ticket_round.dart';
import 'package:flutter/material.dart';
import '../../models/event.dart';

class ListTickets extends StatefulWidget {
  final Ticket ticket;

  const ListTickets({super.key, required this.ticket});

  @override
  ListTicketsState createState() => ListTicketsState();
}

class ListTicketsState extends State<ListTickets> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            //color: Colors.white.withAlpha(30),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TicketRound(
        ticket: widget.ticket,
        initialAmount: 0,
        onAmountChanged: (newAmount) {
          // Handle amount change logic here
        },
      ),
    );
  }
}
