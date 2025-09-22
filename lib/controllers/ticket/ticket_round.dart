import 'package:flutter/material.dart';
import '../../models/event_details.dart';

class TicketRound extends StatefulWidget {
  final Ticket ticket;
  final int initialAmount;
  final ValueChanged<int> onAmountChanged;

  const TicketRound({
    super.key,
    required this.ticket,
    required this.initialAmount,
    required this.onAmountChanged,
  });

  @override
  State<TicketRound> createState() => _TicketRoundState();
}

class _TicketRoundState extends State<TicketRound> {
  late int _amount;

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
  }

  void _updateAmount(int newAmount) {
    final validatedAmount = newAmount < 0 ? 0 : newAmount;
    setState(() {
      _amount = validatedAmount;
    });
    widget.onAmountChanged(validatedAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.ticket.title ?? 'No Title',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _updateAmount(_amount - (widget.ticket.increment ?? 1)),
            ),
            Text(
              '$_amount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _updateAmount(_amount + (widget.ticket.increment ?? 1)),
            ),
          ],
        ),
      ),
    );
  }
}