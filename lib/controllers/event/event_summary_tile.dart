import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';

class EventSummaryTile extends StatelessWidget {
  final Event event;

  const EventSummaryTile({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final double baseHeight = 60;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Event Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.thumbnail,
                  height: baseHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/image_place_holder.png',
                    width: baseHeight,
                    height: baseHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        
            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
          ],
        ),
      ),
    );
  }
}
