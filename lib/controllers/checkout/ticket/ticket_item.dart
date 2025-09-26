import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/checkout/ticket/ticket_price/ticket_price.dart';
import 'package:day_night/models/event_details.dart';
import 'package:flutter/material.dart';

class RegularPrice extends StatelessWidget {
  final EventDetails eventDetails;
  final Ticket ticket;
  final bool soldOut;

  const RegularPrice({
    super.key,
    required this.eventDetails,
    required this.ticket,
    required this.soldOut,
  });

  String _getTicketPrice() {
    if (ticket.pricingType == 'rounds' && soldOut) {
      return ticket.rounds![0].price.toString();
    } else if (ticket.price != null) {
      return ticket.price!;
    } else {
      return 'N/A';
    }
  }
  @override
  Widget build(BuildContext context) {
    final price = _getTicketPrice();

    return Text(
      price,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
      ),
    );
  }

}

class RoundPrice extends StatelessWidget {
  final EventDetails eventDetails;
  final Ticket ticket;
  final bool soldOut;

  const RoundPrice({super.key, required this.eventDetails, required this.ticket, required this.soldOut});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RegularPrice(eventDetails: eventDetails, ticket: ticket, soldOut: soldOut),
        const SizedBox(width: 8), // Add spacing
        Text(
          ticket.rounds![0].price.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: Colors.white.withAlpha(77), // 30% opacity
          ),
        ),
      ],
    );
  }
}

class TicketItem extends StatefulWidget {
  final EventDetails eventDetails; 
  final Ticket ticket;
  final int initialAmount;
  final ValueChanged<int> onAmountChanged;
  final bool isSelected;

  const TicketItem({
    super.key,
    required this.eventDetails,
    required this.ticket,
    required this.initialAmount,
    required this.onAmountChanged,
    required this.isSelected,
  });

  @override
  State<TicketItem> createState() => _TicketItemState();
}

class _TicketItemState extends State<TicketItem> {
  late int _amount;
  late bool _isSoldOut;
  late bool _isComingSoon;

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
    _isSoldOut = isSoldOut();
    _isComingSoon = isComingSoon();
  }

  void _updateAmount(int newAmount) {
    final validatedAmount = newAmount < 0 ? 0 : newAmount;
    setState(() {
      _amount = validatedAmount;
    });
    widget.onAmountChanged(validatedAmount);
  }

  bool isSoldOut() {
    bool isSoldOut = widget.ticket.soldOut || !widget.ticket.available || 
      (widget.ticket.activeRound == null && widget.ticket.rounds != null);

    return isSoldOut;
  }

  bool isComingSoon() {
    return widget.ticket.comingSoon;
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.black.withAlpha(77), // Semi-transparent black background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: widget.isSelected ? BorderSide(color: kBrandPrimary, width: 4.0) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ticket.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(
                      color: widget.isSelected ? kBrandPrimary : Colors.black.withAlpha(200),
                    ),
                  ),
                  widget.ticket.pricingType == 'rounds'
                      ? RoundPrice(eventDetails: widget.eventDetails, soldOut: _isSoldOut, ticket: widget.ticket)
                      : RegularPrice(eventDetails: widget.eventDetails, soldOut: _isSoldOut, ticket: widget.ticket),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).get('processing-fee'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withAlpha(150),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.eventDetails.eventInformation.prcessingFee
                            .toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withAlpha(150),
                        ),
                      ),
                      const SizedBox(width: 3),
                      widget.eventDetails.eventInformation.prcessingFeeType == 'percentage'
                          ? Text(
                              '%',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withAlpha(150),
                                  ),
                            )
                          : Text(
                              AppLocalizations.of(
                                context,
                              ).get('currency-symbol'),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withAlpha(150),
                                  ),
                            ),
                    ],
                  ),
                ],
              ),
            ),

            TicketPrice(
              eventDetails: widget.eventDetails,
              ticket: widget.ticket,
              amount: _amount,
              onAmountChanged: _updateAmount,
              isSoldOut: _isSoldOut,
              isComingSoon: _isComingSoon,
            ),
          ],
        ),
      ),
    );
  }
}