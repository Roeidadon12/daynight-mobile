import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';

class MediaEditSection extends StatelessWidget {
  final OrganizerEvent event;
  final Map<String, dynamic>? initialEventData;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const MediaEditSection({
    super.key,
    required this.event,
    this.initialEventData,
    this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
