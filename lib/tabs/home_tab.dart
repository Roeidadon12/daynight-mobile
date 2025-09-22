import 'package:day_night/controllers/event/horizontal_event_gallery.dart';
import 'package:day_night/controllers/event/event_details_page.dart';
import 'package:day_night/models/events_response.dart';
import 'package:day_night/utils/slide_page_route.dart';
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
import '../constants.dart';

enum HomeTabView {
  today,
  week,
  category,
}

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

  bool _isFirstLoad = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final eventService = EventService();
    setState(() {
      _isLoading = true;
      todayEvents.clear();
      weekEvents.clear();
      displayedEvents.clear();
      upcomingEvents.clear();
    });
    
    try {
      // Fetch all event types in parallel
      final results = await Future.wait([
        eventService.getEventsByDate('today'),
        eventService.getEventsByDate('week'),
        eventService.getEventsByDate('upcoming'),
      ]);
      
      if (mounted) {
        setState(() {
          todayEvents = results[0];
          weekEvents = results[1];
          upcomingEvents = results[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // If this is the first load, automatically select the first available content
    if (_isFirstLoad) {
      _isFirstLoad = false;
      
      // Check in priority order: today events -> week events -> first category
      if (todayEvents.isNotEmpty) {
        onButtonPressed(HomeTabButtonType.today);
      } else if (weekEvents.isNotEmpty) {
        onButtonPressed(HomeTabButtonType.week);
      } else {
        // Get categories and trigger the first category if available
        final categories = getCategoriesByLanguage();
        if (categories.isNotEmpty) {
          onCategoryPressed(categories.first);
        }
      }
    } else if (_currentView == HomeTabView.today && todayEvents.isEmpty) {
      // If currently showing today view but no today events, switch to next available view
      if (weekEvents.isNotEmpty) {
        onButtonPressed(HomeTabButtonType.week);
      } else {
        final categories = getCategoriesByLanguage();
        if (categories.isNotEmpty) {
          onCategoryPressed(categories.first);
        }
      }
    } else if (_currentView == HomeTabView.week && weekEvents.isEmpty) {
      // If currently showing week view but no week events, switch to next available view
      if (todayEvents.isNotEmpty) {
        onButtonPressed(HomeTabButtonType.today);
      } else {
        final categories = getCategoriesByLanguage();
        if (categories.isNotEmpty) {
          onCategoryPressed(categories.first);
        }
      }
    }
  }

  void onButtonPressed(HomeTabButtonType type) {
    setState(() {
      switch (type) {
        case HomeTabButtonType.today:
          displayedEvents = todayEvents;
          _currentView = HomeTabView.today;
          break;
        case HomeTabButtonType.week:
          displayedEvents = weekEvents;
          _currentView = HomeTabView.week;
          break;
      }
    });
    // Update the UI to reflect the selected button
    if (mounted) {
      setState(() {});
    }
  }

  void onCategoryPressed(Category category) async {
    final eventService = EventService();
    // Keep current events until new ones are loaded
    final events = await eventService.getEventsByCategory(kAppLanguageId, category.id);
    if (mounted) {
      setState(() {
        displayedEvents = events;
        _currentCategory = category;
        _currentView = HomeTabView.category;
      });
    }
  }

  HomeTabView _currentView = HomeTabView.today;
  Category? _currentCategory;

  String _getEmptyStateMessage(BuildContext context, [String? displayMessage]) {
    if (displayMessage != null) {
      return AppLocalizations.of(context).get(displayMessage);
    }
    
    switch (_currentView) {
      case HomeTabView.today:
        return AppLocalizations.of(context).get('no-today-events');
      case HomeTabView.week:
        return AppLocalizations.of(context).get('no-week-events');
      case HomeTabView.category:
        final categoryName = _currentCategory?.name ?? '';
        return '${AppLocalizations.of(context).get('no-category-events')} $categoryName';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = getCategoriesByLanguage();
    // Only include buttons for event types that have events
    final labels = <String>[
      if (todayEvents.isNotEmpty)
        AppLocalizations.of(context).get('today-events'),
      if (weekEvents.isNotEmpty)
        AppLocalizations.of(context).get('week-events'),
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
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  HorizontalButtonsController(
                    labels: labels,
                    delegates: {
                      // Only include delegates for event types that have events
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
                    itemSize: 400,
                    onEventTap: (event) {
                      Navigator.push(
                        context,
                        SlidePageRoute(
                          page: EventDetailsPage(event: event),
                        ),
                      );
                    },
                    onRefresh: _fetchEvents,
                    title: AppLocalizations.of(context).get('events'),
                    subtitle: AppLocalizations.of(context).get('tap-to-view'),
                    emptyStateMessage: _getEmptyStateMessage(context),
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
                    itemSize: 300,
                    onEventTap: (event) {
                      Navigator.push(
                        context,
                        SlidePageRoute(
                          page: EventDetailsPage(event: event),
                        ),
                      );
                    },
                    onRefresh: _fetchEvents,
                    title: AppLocalizations.of(context).get('upcoming-events'),
                    subtitle: AppLocalizations.of(context).get('tap-to-view'),
                    emptyStateMessage: _getEmptyStateMessage(context, 'no-upcoming-events'),
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
