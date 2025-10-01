import 'package:day_night/models/ticket.dart';
import 'package:flutter/material.dart';
import '../../../../models/event_details.dart';
import 'ticket_sold_out.dart';
import 'ticket_coming_soon.dart';
import 'ticket_amount_selector.dart';

class TicketPrice extends StatelessWidget {
  final EventDetails eventDetails;
  final Ticket ticket;
  final int amount;
  final Function(int) onAmountChanged;
  final bool isSoldOut;
  final bool isComingSoon;

  const TicketPrice({
    super.key,
    required this.eventDetails,
    required this.ticket,
    required this.amount,
    required this.onAmountChanged,
    required this.isSoldOut,
    required this.isComingSoon,
  });

  Widget _buildCounterState(BuildContext context) {
    final limit = int.tryParse(ticket.saleLimit) ?? 999;
    return TicketAmountSelector(
      amount: amount,
      increment: ticket.increment,
      amountLimit: limit,
      onAmountChanged: onAmountChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    
    if (isComingSoon) {
      child = const TicketComingSoon();
    } else if (isSoldOut) {
      child = const TicketSoldOut();
    } else {
      child = _buildCounterState(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }
}