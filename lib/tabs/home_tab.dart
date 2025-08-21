import 'package:day_night/controllers/event/horizontal_event_gallery.dart';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../controllers/user/user_controller.dart';
import '../controllers/user/user_header.dart';
import '../controllers/shared/horizontal_buttons_controller.dart';
import 'package:provider/provider.dart';
import '../models/enums.dart';
import '../models/category.dart';
import '../utils/category_utils.dart';
import '../services/event_service.dart';
import '../models/event.dart';
import '../constants.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Event> todayEvents = [];
  List<Event> weekEvents = [];
  List<Event> displayedEvents = [];
  List<Event> upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final eventService = EventService();
    setState(() {
      todayEvents.clear();
      weekEvents.clear();
      displayedEvents.clear();
      upcomingEvents.clear();
    });
    final today = await eventService.getEventsByDate('today');
    final week = await eventService.getEventsByDate('week');
    setState(() {
      todayEvents = today;
      weekEvents = week;
      displayedEvents = todayEvents;
    });
  }

  void onButtonPressed(HomeTabButtonType type) {
    setState(() {
      switch (type) {
        case HomeTabButtonType.today:
          displayedEvents = todayEvents;
          break;
        case HomeTabButtonType.week:
          displayedEvents = weekEvents;
          break;
      }
    });
  }

  void onCategoryPressed(Category category) async {
    final eventService = EventService();
    setState(() {
      displayedEvents.clear();
    });
    final events = await eventService.getEventsByCategory(category.id);
    setState(() {
      displayedEvents = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = getCategoriesByLanguage();
    final labels = <String>[
      if (todayEvents.isNotEmpty) AppLocalizations.of(context).get('today-events'),
      if (weekEvents.isNotEmpty) AppLocalizations.of(context).get('week-events'),
      ...categories.map((c) => c.name),
    ];
    return SafeArea(
      child: Container(
        color: kMainBackgroundColor,
        child: Directionality(
          textDirection: Directionality.of(context),
          child: SingleChildScrollView(
            // Added this wrapper
            child: Column(
              children: [
                ChangeNotifierProvider(
                  create: (_) => UserController(),
                  child: Consumer<UserController>(
                    builder: (context, userController, _) {
                      return userController.isLoggedIn
                          ? const UserHeader()
                          : const SizedBox.shrink(); // Returns an empty widget when not logged in
                    },
                  ),
                ),
                HorizontalButtonsController(
                  labels: labels,
                  delegates: {
                    if (todayEvents.isNotEmpty)
                      AppLocalizations.of(context).get('today-events'): () =>
                          onButtonPressed(HomeTabButtonType.today),
                    if (weekEvents.isNotEmpty)
                      AppLocalizations.of(context).get('week-events'): () =>
                          onButtonPressed(HomeTabButtonType.week),
                    ...{
                      for (final cat in categories)
                        cat.name: () => onCategoryPressed(cat),
                    },
                  },
                  height: 56,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: HorizontalEventGallery(
                    events: displayedEvents,
                    onEventTap: (event) {},
                    height: 160,
                    title: AppLocalizations.of(context).get('events'),
                    subtitle: AppLocalizations.of(context).get('tap-to-view'),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        ).get('upcoming-events-label'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Add your button action here
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: kBrandPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(
                          AppLocalizations.of(context).get('view-all'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: kBrandPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: HorizontalEventGallery(
                    events: upcomingEvents,
                    onEventTap: (event) {},
                    height: 100,
                    title: AppLocalizations.of(context).get('upcoming-events'),
                    subtitle: AppLocalizations.of(context).get('tap-to-view'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
