import 'package:flutter/material.dart';

class EventEmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final Widget? customContent;
  final VoidCallback? onRetry;

  const EventEmptyState({
    super.key,
    required this.message,
    this.title,
    this.customContent,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: customContent ?? _buildDefaultContent(),
    );
  }

  Widget _buildDefaultContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,  // Use minimum space needed
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder container for future enhancements (image, animation, etc.)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Icon(
                Icons.refresh,
                color: Colors.white54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
