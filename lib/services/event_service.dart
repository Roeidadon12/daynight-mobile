import '../api_service.dart';
import '../constants.dart';
import '../utils/logger.dart';
import '../models/enums.dart';
import '../models/events_response.dart';

/// Service class responsible for handling all event-related API operations.
///
/// This service provides methods to fetch, search, and filter events from the backend API.
/// It uses the [ApiService] for making HTTP requests and handles the serialization/deserialization
/// of event data.
class EventService {
  /// The API service instance used for making HTTP requests.
  final ApiService api;

  /// Creates a new [EventService] instance.
  ///
  /// Initializes the [ApiService] with the base URL from configuration.
  EventService() : api = ApiService(baseUrl: kApiBaseUrl);

  /// Fetches events filtered by date type.
  ///
  /// [type] specifies the date filter type (e.g., 'upcoming', 'past', 'today').
  ///
  /// Returns a list of [Event] objects. Returns an empty list if the request fails
  /// or if there's an error parsing the response.
  ///
  /// Throws nothing - errors are logged and an empty list is returned.
  Future<List<Event>> getEventsByDate(String type) async {
    var queryParams = <String, String>{};

    switch (type) {
      case 'week':
        queryParams['start_date'] = DateTime.now().toIso8601String().split(
          'T',
        )[0];
        queryParams['end_date'] = DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String()
            .split('T')[0];
        // Handle upcoming events
        break;
      case 'today':
        // Handle today's events
        queryParams['start_date'] = DateTime.now().toIso8601String().split(
          'T',
        )[0];
        queryParams['end_date'] = DateTime.now().toIso8601String().split(
          'T',
        )[0];
        break;
      case 'upcoming':
        queryParams['start_date'] = DateTime.now().toIso8601String().split(
          'T',
        )[0];
        queryParams['end_date'] = DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String()
            .split('T')[0];
        break;
      default:
        // Handle unknown event type
        break;
    }

    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      queryParams: queryParams,
    );

    final events = getEvents(response);
    return events;
  }

  /// Fetches events filtered by price range.
  ///
  /// [minPrice] specifies the minimum price filter.
  /// [maxPrice] specifies the maximum price filter.
  ///
  /// Returns a list of [EventsResponse] objects that fall within the specified price range.
  /// Returns an empty list if the request fails or if there's an error parsing the response.
  ///
  /// Throws nothing - errors are logged and an empty list is returned.
  Future<List<Event>> getEventsByPrice(
    double minPrice,
    double maxPrice, {
    ValidCurrency currency = ValidCurrency.ILS,
  }) async {
    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      queryParams: {
        'min_price': minPrice.toString(),
        'max_price': maxPrice.toString(),
        'currency': currency.toString().split('.').last,
      },
    );

    final events = getEvents(response);
    return events;
  }

  /// Fetches events within a specified price range.
  ///
  /// [rangeFromPrice] is the minimum price (inclusive).
  /// [rangeToPrice] is the maximum price (inclusive).
  ///
  /// Returns a list of [EventsResponse] objects that fall within the specified price range.
  /// Returns an empty list if:
  /// - The price range is invalid (negative prices or min > max)
  /// - The request fails
  /// - There's an error parsing the response
  ///
  /// Throws nothing - errors are logged and an empty list is returned.
  Future<List<Event>> getEventsByPriceRange(
    double rangeFromPrice,
    double rangeToPrice,
  ) async {
    if (rangeFromPrice < 0 ||
        rangeToPrice < 0 ||
        rangeFromPrice > rangeToPrice) {
      Logger.error('Invalid price range', 'EventService');
      return [];
    }

    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      queryParams: {
        'start_price': rangeFromPrice.toString(),
        'end_price': rangeToPrice.toString(),
      },
    );

    final events = getEvents(response);
    return events;
  }

  Future<List<Event>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (startDate.isAfter(endDate)) {
      Logger.error('Start date cannot be after end date', 'EventService');
      return [];
    }

    // Ensure the dates are in the correct format for the API
    final String startDateStr = startDate.toIso8601String().split('T')[0];
    final String endDateStr = endDate.toIso8601String().split('T')[0];
    // Call the API to get events by date range

    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      queryParams: {'start_date': startDateStr, 'end_date': endDateStr},
    );

    final events = getEvents(response);
    return events;
  }

  Future<List<Event>> getEventsByCategory(int language_id, int categoryId) async {
    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      queryParams: {
        'category_id': categoryId.toString(),
        'language_id': language_id.toString(),
      },
    );

    final events = getEvents(response);
    return events;
  }
}

List<Event> getEvents(Map<String, dynamic> response) {
  try {
    if (!response.containsKey('events')) {
      Logger.error('Response missing events key', 'EventService');
      throw Exception('Response missing events key');
    }

    // Parse the entire response into EventsResponse
    final eventsResponse = EventsResponse.fromJson(response);

    // Get the list of events from the data property
    final events = eventsResponse.events.data;

    if (events.isEmpty) {
      Logger.warning('No events returned from API', 'EventService');
    } else {
      Logger.info(
        'Successfully fetched ${events.length} events',
        'EventService',
      );
    }

    return events;
  } catch (e) {
    Logger.error('Error parsing events: $e', 'EventService');
  }  
  
  return [];
}

