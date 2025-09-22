import 'package:day_night/constants.dart';
import 'package:day_night/controllers/ticket/ticket_round.dart';
import 'package:flutter/material.dart';
import '../../models/ticket.dart';

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
        color: kMainBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
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
