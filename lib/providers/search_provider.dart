import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/search_criteria.dart';
import '../services/event_service.dart';
import 'package:day_night/constants.dart';

class SearchProvider extends ChangeNotifier {
  static final SearchProvider _instance = SearchProvider._internal();
  
  List<Event> _searchResults = [];
  List<SearchCriteria> _searchCriteria = [];
  bool _isLoading = false;
  Map<String, dynamic>? _lastSearchParams;
  SearchCriteriaType? _lastSearchType;

  List<Event> get searchResults => _searchResults;
  List<SearchCriteria> get searchCriteria => _searchCriteria;
  bool get isLoading => _isLoading;
  bool get hasActiveSearch => _searchResults.isNotEmpty;
  Map<String, dynamic>? get lastSearchParams => _lastSearchParams;
  SearchCriteriaType? get lastSearchType => _lastSearchType;

  factory SearchProvider() {
    return _instance;
  }

  SearchProvider._internal() {
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
    _lastSearchParams = null;
    _lastSearchType = null;
    
    // Clear selection state
    for (var c in _searchCriteria) {
      c.selected = false;
    }
    
    notifyListeners();
  }

  void saveSearch(SearchCriteriaType type, Map<String, dynamic> params, List<Event> results) {
    _lastSearchType = type;
    _lastSearchParams = params;
    _searchResults = results;
    
    // Update selected criteria
    for (var c in _searchCriteria) {
      c.selected = c.type == type;
    }
    
    notifyListeners();
  }

  Future<void> restoreLastSearch() async {
    if (_lastSearchType == null || _lastSearchParams == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final eventService = EventService();
      List<Event> results = [];

      if (_lastSearchType != null) {
        switch (_lastSearchType!) {
          case SearchCriteriaType.dateCrieteria:
            final startDate = _lastSearchParams!['start'] as DateTime;
            final endDate = _lastSearchParams!['end'] as DateTime;
            results = await eventService.getEventsByDateRange(kAppLanguageId, startDate, endDate);
            break;
          case SearchCriteriaType.priceCriteria:
            // Implement when price search is available
            break;
          case SearchCriteriaType.eventTypeCriteria:
            // Implement when event type search is available
            break;
        }
      }

      _searchResults = results;
      
      // Restore criteria selection
      for (var c in _searchCriteria) {
        c.selected = c.type == _lastSearchType;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
