import 'package:day_night/controllers/event/event_summary_tile.dart';
import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';
import 'event_details_page.dart';
import '../../utils/slide_page_route.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventListItem({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {

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
