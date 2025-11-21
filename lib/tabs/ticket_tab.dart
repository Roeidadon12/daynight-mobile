import 'package:day_night/controllers/shared/horizontal_buttons_controller.dart';
import 'package:day_night/models/enums.dart';
import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../constants.dart';
import '../controllers/event/event_list_item.dart';

class TicketTab extends StatefulWidget {
  const TicketTab({super.key});

  @override
  State<TicketTab> createState() => _TicketTabState();
}

class _TicketTabState extends State<TicketTab>
    with AutomaticKeepAliveClientMixin {
  List<Event> favoriteEvents = [];
  List<Event> closedEvents = [];
  List<Event> upcomingEvents = [];
  int _selectedFilterIndex = 0; // Track selected filter (default to upcoming)

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibilityAndRestore();
    });
  }

  void _checkVisibilityAndRestore() {
    if (mounted) {
      final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
      if (isVisible) {
        // Perform any necessary actions when the tab becomes visible
      }
    }
  }

  void onFilterButtonPressed(FilterTicketsButtonType type) {
    // Implement filter button action
    setState(() {
      // Update selected index based on filter type
      switch (type) {
        case FilterTicketsButtonType.upcoming:
          _selectedFilterIndex = 0;
          break;
        case FilterTicketsButtonType.closed:
          _selectedFilterIndex = 1;
          break;
        case FilterTicketsButtonType.favorite:
          _selectedFilterIndex = 2;
          break;
      }
    });
  }

  Widget _buildEventsList() {
    // Combine all events for now - you can implement filtering logic here
    final allEvents = [...upcomingEvents, ...closedEvents, ...favoriteEvents];

    if (allEvents.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).get('no-results'),
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: allEvents.length,
      itemBuilder: (context, index) {
        final event = allEvents[index];
        return EventListItem(
          event: event,
          onTap: () {
            // TODO: Handle event tap - navigate to event details or tickets
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final labels = [
      AppLocalizations.of(context).get('upcoming-events'),
      AppLocalizations.of(context).get('closed-events'),
      AppLocalizations.of(context).get('favorite-events'),
    ];

    return SafeArea(
      child: Container(
        color: kMainBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Page Title
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                AppLocalizations.of(
                  context,
                ).get('my-tickets'), // or whatever key you use for tickets
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 2. Horizontal Buttons Controller
            HorizontalButtonsController(
              labels: labels,
              selectedIndex: _selectedFilterIndex,
              delegates: {
                AppLocalizations.of(context).get('upcoming-events'): () =>
                    onFilterButtonPressed(FilterTicketsButtonType.upcoming),
                AppLocalizations.of(context).get('closed-events'): () =>
                    onFilterButtonPressed(FilterTicketsButtonType.closed),
                AppLocalizations.of(context).get('favorite-events'): () =>
                    onFilterButtonPressed(FilterTicketsButtonType.favorite),
              },
              height: 48,
            ),

            const SizedBox(height: 24),

            // 3. Results List
            Expanded(child: _buildEventsList()),
          ],
        ),
      ),
    );
  }
}
