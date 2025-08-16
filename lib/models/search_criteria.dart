enum SearchCriteriaType {
  dateCrieteria,
  priceCriteria,
  eventTypeCriteria,
}

class SearchCriteria {
  final SearchCriteriaType type;
  String text;
  bool selected;  // Add selected property

  SearchCriteria({
    required this.type,
    this.text = '',
    this.selected = false,  // Default to not selected
  });
}