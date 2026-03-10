import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';

class GeneralEditSection extends StatelessWidget {
  final OrganizerEvent event;
  final Map<String, dynamic>? initialEventData;
  final VoidCallback? onNext;

  const GeneralEditSection({
    super.key,
    required this.event,
    this.initialEventData,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
