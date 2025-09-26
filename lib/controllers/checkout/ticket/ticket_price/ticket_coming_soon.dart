import 'package:flutter/material.dart';
import '../../../../app_localizations.dart';
import '../../../../constants.dart';

class TicketComingSoon extends StatelessWidget {
  const TicketComingSoon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBrandPrimary, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          AppLocalizations.of(context).get('coming-soon'),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: kBrandPrimary,
          ),
        ),
      ),
    );
  }
}