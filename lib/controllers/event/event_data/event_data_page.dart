import 'package:flutter/material.dart';
import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/models/events.dart';

class EventDataPage extends StatelessWidget {
  final OrganizerEvent event;

  const EventDataPage({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: AppBar(
        backgroundColor: kMainBackgroundColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(localizations.get('event-data')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
