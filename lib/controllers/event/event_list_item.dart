import 'package:day_night/controllers/event/event_summary_tile.dart';
import 'package:flutter/material.dart';
import '../../models/event.dart';
import 'event_details_page.dart';
import '../../utils/slide_page_route.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventListItem({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final double baseHeight = 60;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
        Navigator.push(
          context,
          SlidePageRoute(page: EventDetailsPage(event: event)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Event Image
            if (event.thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: Image.network(
                  event.thumbnailUrl!,
                  width: baseHeight,
                  height: baseHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 40),
                ),
              )
            else
              Container(
                width: baseHeight,
                height: baseHeight,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),

            // Event Details
            EventSummaryTile(event: event),
            // Directional Icon
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Directionality.of(context) == TextDirection.ltr
                    ? Icons.chevron_right
                    : Icons.chevron_left,
                color: Colors.grey[400],
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
