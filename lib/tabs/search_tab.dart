import 'package:day_night/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import '../controllers/shared/horizontal_buttons_controller.dart';
import '../constants.dart';
import '../controllers/search/search_criteria_button.dart';
import '../models/search_criteria.dart';
import '../controllers/search/search_date_criteria.dart';
import '../controllers/search/show_price_range.dart';
import '../services/event_service.dart';
import '../controllers/event/event_list_item.dart';
import '../providers/search_provider.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  late final SearchProvider _searchProvider;

  @override
  void initState() {
    super.initState();
    _searchProvider = Provider.of<SearchProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final criteria = _searchProvider.searchCriteria;
    // Update texts with localized strings
    for (var c in criteria) {
      switch (c.type) {
        case SearchCriteriaType.dateCrieteria:
          c.text = AppLocalizations.of(context).get('criteria-date');
          break;
        case SearchCriteriaType.priceCriteria:
          c.text = AppLocalizations.of(context).get('criteria-price');
          break;
        case SearchCriteriaType.eventTypeCriteria:
          c.text = AppLocalizations.of(context).get('criteria-event-type');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
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
                  labels: searchProvider.searchCriteria.map((c) => c.text).toList(),
                  selectedIndex: searchProvider.searchCriteria.indexWhere((c) => c.selected),
                  delegates: {
                    for (final criteria in searchProvider.searchCriteria)
                      criteria.text: () => _onSearchCriteriaSelected(criteria),
                  },
                  height: 48,
                ),

                const SizedBox(height: 24),

                // 4. Search Results List
                Expanded(
                  child: searchProvider.searchResults.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context).get('no-results'),
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: searchProvider.searchResults.length,
                          itemBuilder: (context, index) {
                            final event = searchProvider.searchResults[index];
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
      },
    );
  }

  void _onSearchCriteriaSelected(SearchCriteria criteria) async {
    switch (criteria.type) {
      case SearchCriteriaType.dateCrieteria:
        final result = await showCustomDatePicker(context);
        if (result != null &&
            result['start'] != null &&
            result['end'] != null) {
          final DateTime startDate = result['start']!;
          final DateTime endDate = result['end']!;
          final eventService = EventService();
          final events = await eventService.getEventsByDateRange(
            startDate,
            endDate,
          );
          _searchProvider.setSearchResults(events);
        }
        break;
      case SearchCriteriaType.priceCriteria:
        final result = await showCustomPriceRange(context);
        if (result != null &&
            result['min'] != null &&
            result['max'] != null &&
            result['currency'] != null) {
          final double minPrice = result['min'] as double;
          final double maxPrice = result['max'] as double;
          final ValidCurrency currency = result['currency'] as ValidCurrency;
          final eventService = EventService();
          final events = await eventService.getEventsByPrice(
            minPrice,
            maxPrice,
            currency: currency,
          );
          _searchProvider.setSearchResults(events);
        }
        break;
      case SearchCriteriaType.eventTypeCriteria:
        // TODO: Implement event type search
        break;
    }
  }
}