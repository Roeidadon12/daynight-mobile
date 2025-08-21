import 'package:flutter/material.dart';
import '../../models/event.dart';

class ListTickets extends StatefulWidget {
  final Ticket item;

  const ListTickets({super.key, required this.item});

  @override
  ListTicketsState createState() => ListTicketsState();
}

class ListTicketsState extends State<ListTickets> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          title: Text(widget.item.title ?? 'No Title'),
          subtitle: Text("Ticket ID: ${widget.item.id ?? 'N/A'}"),
        ),
      ),
    );
  }
}
