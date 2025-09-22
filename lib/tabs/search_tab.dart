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
import 'package:day_night/constants.dart';


class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with AutomaticKeepAliveClientMixin {
  late final SearchProvider _searchProvider;
  bool _isVisible = false;
  final Map<String, dynamic> _searchResult = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchProvider = Provider.of<SearchProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibilityAndRestore();
    });
  }

  void _checkVisibilityAndRestore() {
    if (mounted) {
      final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
      if (isVisible && !_isVisible) {
        _searchProvider.restoreLastSearch();
      }
      _isVisible = isVisible;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkVisibilityAndRestore();
    
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
    super.build(context);
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
                    AppLocalizations.of(context).get('search'),
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
        final searchResult = await showCustomDatePicker(context);
        if (searchResult != null &&
            searchResult['start_date'] != null &&
            searchResult['end_date'] != null) {

          _searchResult['start_date'] = searchResult['start_date']?.toIso8601String().split('T')[0];
          _searchResult['end_date'] = searchResult['end_date']?.toIso8601String().split('T')[0];

          final eventService = EventService();
          final events = await eventService.getEventsByCriteria(kAppLanguageId, _searchResult);
         _searchProvider.setSearchResults(events);
        }
        break;
      case SearchCriteriaType.priceCriteria:
        final priceResult = await showCustomPriceRange(context);
        if (priceResult != null &&
            priceResult['min'] != null &&
            priceResult['max'] != null &&
            priceResult['currency'] != null) {
          _searchResult['min'] = priceResult['min'];
          _searchResult['max'] = priceResult['max'];
          _searchResult['currency'] = priceResult['currency'];
          
          final eventService = EventService();
          final events = await eventService.getEventsByCriteria(kAppLanguageId, _searchResult);
          _searchProvider.setSearchResults(events);
        }
        break;
      case SearchCriteriaType.eventTypeCriteria:
        // TODO: Implement event type search
        break;
    }
    
    // Trigger a rebuild if needed
    setState(() {});
  }
}