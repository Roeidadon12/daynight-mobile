import 'dart:io';
import 'api_service.dart';
import '../constants.dart';
import '../utils/logger.dart';
import '../utils/api_headers.dart';
import '../models/enums.dart';
import '../models/events.dart';
import '../models/event_details.dart';

/// Service class responsible for handling all event-related API operations.
///
/// This service provides methods to fetch, search, and filter events from the backend API.
/// It uses the [ApiService] for making HTTP requests and handles the serialization/deserialization
/// of event data.
class EventService {
  /// The API service instance used for making HTTP requests.
  final ApiService api;

  /// The API service instance used for event management operations.
  final ApiService dashboardApi;

  /// Creates a new [EventService] instance.
  ///
  /// Initializes the [ApiService] with the base URL from configuration.
  EventService()
    : api = ApiService(baseUrl: kApiBaseUrl),
      dashboardApi = ApiService(baseUrl: kApiStorePath);

  /// Fetches events filtered by date type.
  ///
  /// [type] specifies the date filter type (e.g., 'upcoming', 'past', 'today').
  ///
  /// Returns a list of [Event] objects. Returns an empty list if the request fails
  /// or if there's an error parsing the response.
  ///
  /// Throws nothing - errors are logged and an empty list is returned.
  Future<List<Event>> getEventsByDate(String type) async {
    final Map<String, dynamic> searchResult = {};

    switch (type) {
      case 'week':
        searchResult['start_date'] = DateTime.now().toIso8601String().split(
          'T',
        )[0];
        searchResult['end_date'] = DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String()
            .split('T')[0];
        // Handle upcoming events
        break;
      case 'today':
        // Handle today's events
        searchResult['start_date'] = DateTime.now().toIso8601String().split(
          'T',
        )[0];
        searchResult['end_date'] = DateTime.now().toIso8601String().split(
          'T',
        )[0];
        break;
      case 'upcoming':
        searchResult['start_date'] = DateTime.now().toIso8601String().split(
          'T',
        )[0];
        searchResult['end_date'] = DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String()
            .split('T')[0];
        break;
      default:
        // Handle unknown event type
        break;
    }

    final eventService = EventService();
    final events = await eventService.getEventsByCriteria(
      kAppLanguageId,
      searchResult,
    );

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
  Future<List<Event>> getAllEvents() async {
    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      headers: await ApiHeaders.buildPublic(),
    );

    return getEvents(response);
  }

  Future<List<Event>> getEventsByPrice(
    double minPrice,
    double maxPrice, {
    ValidCurrency currency = ValidCurrency.ils,
  }) async {
    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      queryParams: {
        'min_price': minPrice.toString(),
        'max_price': maxPrice.toString(),
        'currency': currency.toString().split('.').last,
      },
      headers: await ApiHeaders.buildPublic(),
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
    int languageId,
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
        'language_id': languageId.toString(),
      },
      headers: await ApiHeaders.buildPublic(),
    );

    final events = getEvents(response);
    return events;
  }

  Future<List<Event>> getEventsByDateRange(
    int languageId,
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
      queryParams: {
        'start_date': startDateStr,
        'end_date': endDateStr,
        'language_id': languageId.toString(),
      },
      headers: await ApiHeaders.buildPublic(),
    );

    final events = getEvents(response);
    return events;
  }

  Future<List<Event>> getEventsByCategory(
    int languageId,
    int categoryId,
  ) async {
    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      queryParams: {
        'category_id': categoryId.toString(),
        'language_id': languageId.toString(),
      },
      headers: await ApiHeaders.buildPublic(),
    );

    final events = getEvents(response);
    return events;
  }

  Future<List<Event>> getEventsByCriteria(
    int languageId,
    Map<String, dynamic> criteria,
  ) async {
    final cleanedCriteria = Map<String, dynamic>.from(criteria)
      ..removeWhere((key, value) => value == null || value.toString().isEmpty)
      ..addAll({'language_id': languageId.toString()});

    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      queryParams: cleanedCriteria,
      headers: await ApiHeaders.buildPublic(),
    );

    final events = getEvents(response);
    return events;
  }

  Future<EventDetails?> getEventById(int languageId, int eventId) async {
    final response = await api.request(
      endpoint: ApiCommands.getEventDetails.value,
      method: 'GET',
      queryParams: {
        'language_id': languageId.toString(),
        'event_id': eventId.toString(),
      },
      headers: await ApiHeaders.buildPublic(),
    );

    try {
      if (!response.containsKey('status')) {
        Logger.error('Response missing status', 'EventService');
        return null;
      }

      final eventDetails = EventDetails.fromJson(response);
      Logger.info(
        'Successfully fetched event details with ID $eventId',
        'EventService',
      );
      return eventDetails;
    } catch (e) {
      Logger.error('Error parsing event details: $e', 'EventService');
      return null;
    }
  }

  /// Creates a new event by submitting event data to the backend API.
  ///
  /// [eventData] contains all the event information to be submitted
  /// [additionalFormData] contains extra fields from the create event form
  ///
  /// Returns the created event's ID if successful, null if failed.
  ///
  /// Throws [ServerException] if the request fails with a server error.
  Future<int?> createEvent(
    Map<String, dynamic> eventData,
    Map<String, dynamic> additionalFormData,
  ) async {
    try {
      Logger.info(
        'Creating event with data: ${eventData.keys.join(', ')}',
        'EventService',
      );

      // Check if there's an image file to upload
      String? imagePath = eventData['cover_image'] as String?;
      File? imageFile;

      if (imagePath != null && imagePath.isNotEmpty && imagePath != '') {
        imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          Logger.warning(
            'Image file does not exist: $imagePath',
            'EventService',
          );
          imageFile = null;
        }
      }

      Map<String, dynamic> response;

      if (imageFile != null) {
        // Use multipart request for image upload
        response = await _createEventWithImage(eventData, imageFile);
      } else {
        // Use regular JSON request if no image
        final dataWithoutImage = Map<String, dynamic>.from(eventData);
        dataWithoutImage.remove(
          'cover_image',
        ); // Remove image path from JSON data

        response = await dashboardApi.request(
          endpoint: ApiCommands.createEvent.value,
          method: 'POST',
          body: dataWithoutImage,
          headers: await ApiHeaders.buildHeader(null, true),
        );
      }

      if (response.containsKey('status') && response['status'] == 'success') {
        final eventId = response['event_id'] as int?;
        if (eventId != null) {
          Logger.info(
            'Successfully created event with ID: $eventId',
            'EventService',
          );
          return eventId;
        }
      }

      Logger.error(
        'Failed to create event: Invalid response format',
        'EventService',
      );
      return null;
    } catch (e) {
      Logger.error('Error creating event: $e', 'EventService');
      return null;
    }
  }

  /// Helper method to create event with image using multipart/form-data
  Future<Map<String, dynamic>> _createEventWithImage(
    Map<String, dynamic> eventData,
    File imageFile,
  ) async {
    try {
      // Prepare form fields (exclude cover_image as it will be added as file)
      final formFields = <String, String>{};
      eventData.forEach((key, value) {
        if (key != 'cover_image' && value != null) {
          formFields[key] = value.toString();
        }
      });

      Logger.info(
        'Creating event with image using dashboardApi',
        'EventService',
      );

      final response = await dashboardApi.postMultipart(
        ApiCommands.createEvent.value,
        fields: formFields,
        files: {'cover_image': imageFile},
        headers: await ApiHeaders.buildMultipartHeaders(null, true),
      );

      Logger.info(
        'Event creation request completed successfully',
        'EventService',
      );
      return response;
    } catch (e) {
      Logger.error('Error in event creation with image: $e', 'EventService');
      rethrow;
    }
  }

  List<Event> getEvents(Map<String, dynamic>? response) {
    try {
      if (response == null) {
        Logger.error('Response is null', 'EventService');
        throw Exception('Response is null');
      }

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
}
