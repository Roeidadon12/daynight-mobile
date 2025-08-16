import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../constants.dart';
import 'event_details_page.dart';
import '../../utils/slide_page_route.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventListItem({
    super.key,
    required this.event,
    this.onTap,
  });

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
          SlidePageRoute(
            page: EventDetailsPage(event: event),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Event Image
            if (event.thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
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
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                ),
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            
            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.information?['title'] ?? 'No Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          event.startShortDate,
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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