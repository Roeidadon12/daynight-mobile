/// Enum representing the types of buttons in the HomeTab horizontal button controller.
enum HomeTabButtonType {
  today,
  week,
}

enum SearchCriteriaType {
  dateCrieteria,
  priceCriteria,
  eventTypeCriteria,
}

enum ValidCurrency {
  ILS, // Israeli Shekel
  USD, // US Dollar
  EUR, // Euro
  GBP, // British Pound
}

enum ApiCommands {
  getCategories('/categories'),
  getEvents('/events'),
  getEventDetails('/event/details'),
  updateEvent('/events'),
  deleteEvent('/events'),
  getLanguages('/languages');

  final String value;
  const ApiCommands(this.value);
}