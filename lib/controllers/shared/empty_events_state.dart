import 'package:flutter/material.dart';
import '../../constants.dart';

class EmptyEventsState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyEventsState({
    super.key,
    required this.message,
    this.icon = Icons.event_busy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: kBrandPrimary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
