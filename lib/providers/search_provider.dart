import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/enums.dart';
import '../models/search_criteria.dart';

class SearchProvider extends ChangeNotifier {
  List<Event> _searchResults = [];
  List<SearchCriteria> _searchCriteria = [];
  bool _isLoading = false;

  List<Event> get searchResults => _searchResults;
  List<SearchCriteria> get searchCriteria => _searchCriteria;
  bool get isLoading => _isLoading;

  SearchProvider() {
    _initializeCriteria();
  }

  void _initializeCriteria() {
    _searchCriteria = [
      SearchCriteria(
        type: SearchCriteriaType.dateCrieteria,
        text: '',
      ),
      SearchCriteria(type: SearchCriteriaType.priceCriteria, text: ''),
      SearchCriteria(type: SearchCriteriaType.eventTypeCriteria, text: ''),
    ];
  }

  void updateCriteriaTexts(BuildContext context) {
    _getCriteriaByType(SearchCriteriaType.dateCrieteria).text =
        'criteria-date';
    _getCriteriaByType(SearchCriteriaType.priceCriteria).text =
        'criteria-price';
    _getCriteriaByType(SearchCriteriaType.eventTypeCriteria).text =
        'criteria-event-type';
    notifyListeners();
  }

  SearchCriteria _getCriteriaByType(SearchCriteriaType type) {
    return _searchCriteria.firstWhere((criteria) => criteria.type == type);
  }

  Future<void> onSearchCriteriaSelected(SearchCriteria criteria) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update criteria selection state
      for (var c in _searchCriteria) {
        c.selected = c.type == criteria.type;
      }

      switch (criteria.type) {
        case SearchCriteriaType.dateCrieteria:
          // Date criteria handling would go here
          break;
        case SearchCriteriaType.priceCriteria:
          // Price criteria handling would go here
          break;
        case SearchCriteriaType.eventTypeCriteria:
          // Event type criteria handling would go here
          break;
      }

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchResults(List<Event> results) {
    _searchResults = results;
    notifyListeners();
  }

  void clearResults() {
    _searchResults = [];
    notifyListeners();
  }
}
