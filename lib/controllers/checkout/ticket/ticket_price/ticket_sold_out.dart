import 'package:flutter/material.dart';
import '../../../../app_localizations.dart';

class TicketSoldOut extends StatelessWidget {
  const TicketSoldOut({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          AppLocalizations.of(context).get('sold-out'),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}