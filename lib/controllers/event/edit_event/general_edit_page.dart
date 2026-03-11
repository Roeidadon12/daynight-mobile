import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/events.dart';
import 'package:day_night/controllers/event/create_event/new_event_pages/new_event_step1.dart';
import 'package:flutter/material.dart';

class GeneralEditSection extends StatelessWidget {
  final OrganizerEvent event;
  final EventEditDetails? initialEventData;
  final Map<String, dynamic> eventData;
  final Function(String, dynamic) onDataChanged;
  final VoidCallback? onNext;

  const GeneralEditSection({
    super.key,
    required this.event,
    this.initialEventData,
    required this.eventData,
    required this.onDataChanged,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return NewEventStep1(
      eventData: eventData,
      initialEventData: initialEventData,
      onDataChanged: onDataChanged,
      onNext: onNext ?? () {},
    );
  }
}
