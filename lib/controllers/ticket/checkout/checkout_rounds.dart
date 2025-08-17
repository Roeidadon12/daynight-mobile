import 'package:day_night/models/event.dart';
import 'package:flutter/material.dart';

class CheckoutRoundsPage extends StatelessWidget {
  final Event event;

  const CheckoutRoundsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> tickets = event.tickets ?? [];

    return ListView(
      children: tickets.map((item) => ListTicketsWidget(item: item)).toList(),
    );
  }
}

class ListTicketsWidget extends StatefulWidget {
  final MyItem item;

  const ListTicketsWidget({super.key, required this.item});

  @override
  ListTicketsWidgetState createState() => ListTicketsWidgetState();
}

class ListTicketsWidgetState extends State<ListTicketsWidget> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.item.title),
      trailing: DropdownButton<String>(
        value: selectedValue,
        items: widget.item.options
            .map((val) => DropdownMenuItem(
                  value: val,
                  child: Text(val),
                ))
            .toList(),
        onChanged: (val) {
          setState(() {
            selectedValue = val!;
          });
        },
      ),
    );
  }
}

class MyItem {
  final String title;
  final List<String> options;

  MyItem(this.title, this.options);
}