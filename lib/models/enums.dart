/// Enum representing the types of buttons in the HomeTab horizontal button controller.
enum HomeTabButtonType {
  today,
  week,
}

enum FilterTicketsButtonType {
  upcoming,
  closed,
  favorite,
}

enum FilterEditingButtonType {
  myEvents,
  drafts,
  published,
}

enum SearchCriteriaType {
  dateCrieteria,
  priceCriteria,
  eventTypeCriteria,
}

enum ValidCurrency {
  ils, // Israeli Shekel
  usd, // US Dollar
  eur, // Euro
  gbp, // British Pound
}

enum ApiCommands {
  getCategories('/categories'),
  getEvents('/events'),
  getEventDetails('/event/details'),
  createEvent('/event-management/store/'),
  updateEvent('/events'),
  deleteEvent('/events'),
  getLanguages('/languages'),
  getSendOtp('/send-otp'),
  verifyOtp('/verify-otp'),
  processPayment('/payment/process');

  final String value;
  const ApiCommands(this.value);
}