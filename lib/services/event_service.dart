import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
    final events = await eventService.getEventsByCriteria(kAppLanguageId, searchResult);

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
    );

    final events = getEvents(response);
    return events;
  }

  Future<List<Event>> getEventsByCategory(int languageId, int categoryId) async {
    final response = await api.request(
      endpoint: ApiCommands.getEvents.value,
      method: 'GET',
      queryParams: {
        'category_id': categoryId.toString(),
        'language_id': languageId.toString(),
      },
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
    );

    try {
      if (!response.containsKey('status')) {
        Logger.error('Response missing status', 'EventService');
        return null;
      }

      final eventDetails = EventDetails.fromJson(response);
      Logger.info('Successfully fetched event details with ID $eventId', 'EventService');
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
  Future<int?> createEvent(Map<String, dynamic> eventData, Map<String, dynamic> additionalFormData) async {
    try {
      Logger.info('Creating event with data: ${eventData.keys.join(', ')}', 'EventService');
      
      // Check if there's an image file to upload
      String? imagePath = eventData['cover_image'] as String?;
      File? imageFile;
      
      if (imagePath != null && imagePath.isNotEmpty && imagePath != '') {
        imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          Logger.warning('Image file does not exist: $imagePath', 'EventService');
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
        dataWithoutImage.remove('cover_image'); // Remove image path from JSON data
        
        response = await api.request(
          endpoint: ApiCommands.createEvent.value,
          method: 'POST',
          body: dataWithoutImage,
          headers: await ApiHeaders.buildHeader(null, true),
        );
      }

      if (response.containsKey('status') && response['status'] == 'success') {
        final eventId = response['event_id'] as int?;
        if (eventId != null) {
          Logger.info('Successfully created event with ID: $eventId', 'EventService');
          return eventId;
        }
      }
      
      Logger.error('Failed to create event: Invalid response format', 'EventService');
      return null;
    } catch (e) {
      Logger.error('Error creating event: $e', 'EventService');
      return null;
    }
  }
  
  /// Helper method to create event with image using multipart/form-data
  Future<Map<String, dynamic>> _createEventWithImage(Map<String, dynamic> eventData, File imageFile) async {
    try {
      final cleanEndpoint = ApiCommands.createEvent.value.startsWith('/') 
          ? ApiCommands.createEvent.value.substring(1) 
          : ApiCommands.createEvent.value;
      final cleanBaseUrl = kApiStorePath.endsWith('/') 
          ? kApiStorePath.substring(0, kApiStorePath.length - 1) 
          : kApiStorePath;
      final url = '$cleanBaseUrl/$cleanEndpoint';
      final uri = Uri.parse(url);
      
      Logger.info('Creating multipart request to: $uri', 'EventService');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = await ApiHeaders.buildMediaHeaders(null, true);
      request.headers.addAll(headers);
      
      // Add all text fields
      eventData.forEach((key, value) {
        if (key != 'cover_image' && value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add image file
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'cover_image', // The field name expected by the server
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
      
      // Generate cURL command for debugging if enabled
      if (kEnableDebugCurlOutput) {
        final curlCommand = _generateMultipartCurlCommand(
          uri: uri,
          headers: request.headers,
          fields: request.fields,
          imageFile: imageFile,
        );
        // Output to stderr for clean copy-paste without Flutter prefixes
        stderr.writeln('');
        stderr.writeln('=== COPY THIS MULTIPART CURL COMMAND ===');
        stderr.writeln(curlCommand);
        stderr.writeln('=== END CURL COMMAND ===');
        stderr.writeln('');
      }
      
      Logger.info('Sending multipart request with ${request.fields.length} fields and ${request.files.length} files', 'EventService');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      Logger.info('Multipart request completed with status: ${response.statusCode}', 'EventService');
      
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(
          const JsonDecoder().convert(response.body) as Map
        );
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error in multipart request: $e', 'EventService');
      rethrow;
    }
  }

  /// Generates a curl command equivalent to the multipart HTTP request for debugging.
  String _generateMultipartCurlCommand({
    required Uri uri,
    required Map<String, String> headers,
    required Map<String, String> fields,
    required File imageFile,
  }) {
    final buffer = StringBuffer();
    
    // Start with curl command and method
    buffer.write('curl -X POST');
    
    // Add URL
    buffer.write(' \\\n  "$uri"');
    
    // Add headers (excluding Content-Type for multipart as curl handles it)
    headers.forEach((key, value) {
      if (key.toLowerCase() != 'content-type') {
        buffer.write(' \\\n  -H "$key: $value"');
      }
    });
    
    // Add form fields
    fields.forEach((key, value) {
      // Escape quotes and special characters
      final escapedValue = value.replaceAll('"', '\\"').replaceAll('\$', '\\\$');
      buffer.write(' \\\n  -F "$key=$escapedValue"');
    });
    
    // Add image file
    final filename = imageFile.path.split('/').last;
    buffer.write(' \\\n  -F "cover_image=@${imageFile.path};filename=$filename"');
    
    return buffer.toString();
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

