import 'package:flutter/material.dart';
import '../app_localizations.dart';

class TicketTab extends StatelessWidget {
  const TicketTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Center(
        child: Text(
          AppLocalizations.of(context).get('ticket - page'),
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
