import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/events.dart';
import 'package:day_night/controllers/event/create_event/new_event_pages/new_event_step2.dart';
import 'package:flutter/material.dart';

class MediaEditSection extends StatelessWidget {
  final OrganizerEvent event;
  final EventEditDetails? initialEventData;
  final Map<String, dynamic> eventData;
  final Function(String, dynamic) onDataChanged;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const MediaEditSection({
    super.key,
    required this.event,
    this.initialEventData,
    required this.eventData,
    required this.onDataChanged,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return NewEventStep2(
      eventData: eventData,
      onDataChanged: onDataChanged,
      onNext: onNext ?? () {},
      onPrevious: onPrevious ?? () {},
    );
  }
}
