import 'package:flutter/material.dart';

class TicketAmountSelector extends StatelessWidget {
  final int amount;
  final int increment;
  final int amountLimit;
  final Function(int) onAmountChanged;

  const TicketAmountSelector({
    super.key,
    required this.amount,
    required this.increment,
    required this.amountLimit,
    required this.onAmountChanged,
  });

  void _updateAmount(int newAmount) {
    if (newAmount < 0) {
      onAmountChanged(0);
    } else if (newAmount > amountLimit) {
      onAmountChanged(amountLimit);
    } else {
      onAmountChanged(newAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(200),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.remove, color: Colors.white),
            onPressed: () => _updateAmount(amount - increment),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: const BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text(
              '$amount',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(200),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _updateAmount(amount + increment),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
            ),
          ),
        ),
      ],
    );
  }
}