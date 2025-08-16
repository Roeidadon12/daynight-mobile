import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/event.dart';
import '../controllers/shared/horizontal_buttons_controller.dart';
import '../constants.dart';
import '../controllers/search/search_criteria_button.dart';
import '../models/search_criteria.dart';
import '../controllers/search/search_date_criteria.dart'; // Add this import
import '../services/event_service.dart';
import '../controllers/event/event_list_item.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  List<Event> searchResults = [];
  List<SearchCriteria> searchCriteria = []; 

  @override
  void initState() {
    super.initState();
    searchCriteria = [
      SearchCriteria(
        type: SearchCriteriaType.dateCrieteria,
        text: '',  // We'll update these in didChangeDependencies
      ),
      SearchCriteria(
        type: SearchCriteriaType.priceCriteria,
        text: '',
      ),
      SearchCriteria(
        type: SearchCriteriaType.eventTypeCriteria,
        text: '',
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update texts with localized strings
    _getCriteriaByType(SearchCriteriaType.dateCrieteria).text = AppLocalizations.of(context).get('criteria-date');
    _getCriteriaByType(SearchCriteriaType.priceCriteria).text = AppLocalizations.of(context).get('criteria-price');
    _getCriteriaByType(SearchCriteriaType.eventTypeCriteria).text = AppLocalizations.of(context).get('criteria-event-type');
  }

  SearchCriteria _getCriteriaByType(SearchCriteriaType type) {
    return searchCriteria.firstWhere((criteria) => criteria.type == type);
  }

  @override
  Widget build(BuildContext context) {

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
                AppLocalizations.of(context).get('search-events'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 2. Search Button (placeholder for now)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SearchCriteriaButton(
                onTap: () {
                  // TODO: Implement search functionality
                },
                height: 56.0, 
              ),
            ),

            const SizedBox(height: 24),

            // 3. Horizontal Buttons Controller
            HorizontalButtonsController(
              labels: searchCriteria.map((c) => c.text).toList(),
              selectedIndex: searchCriteria.indexWhere((c) => c.selected),
              delegates: {
                for (final criteria in searchCriteria)
                  criteria.text: () => _onSearchCriteriaSelected(criteria),
              },
              height: 48,
            ),

            const SizedBox(height: 24),

            // 4. Search Results List
            Expanded(
              child: searchResults.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context).get('no-results'),
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final event = searchResults[index];
                        return EventListItem(
                          event: event,
                          onTap: () {
                            // TODO: Handle event tap
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchCriteriaSelected(SearchCriteria criteria) async {
    final eventService = EventService();
    // Now you can switch on criteria.type
    setState(() {
      for (var c in searchCriteria) {
        c.selected = c.type == criteria.type;
      }
    });

    switch (criteria.type) {
      case SearchCriteriaType.dateCrieteria:
        final result = await showCustomDatePicker(context);
        if (result != null && result['start'] != null && result['end'] != null) {
          final DateTime startDate = result['start']!;
          final DateTime endDate = result['end']!;
          
          // Call the service to get events for the selected date range
          final events = await eventService.getEventsByDateRange(startDate, endDate);
          
          setState(() {
            searchResults = events;
          });
        } else {
          // If no dates selected, deselect the criteria
          setState(() {
            criteria.selected = false;
          });
        }
        break;
      case SearchCriteriaType.priceCriteria:
        // Handle price criteria
        break;
      case SearchCriteriaType.eventTypeCriteria:
        // Handle event type criteria
        break;
    }
    
    setState(() {
      // Update searchResults based on selected criteria
    });
  }
}