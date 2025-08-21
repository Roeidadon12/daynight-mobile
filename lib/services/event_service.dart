import '../api_service.dart';
import '../constants.dart';
import 'dart:convert';
import '../models/event.dart';
import '../utils/logger.dart';

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
    final response = await api.request(
      endpoint: '/events-by-date',
      method: 'GET',
      queryParams: {'type': type},
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromJson(json as Map<String, dynamic>)).toList();
      } catch (e) {
        Logger.error(
          'Failed to parse events from API response',
          'EventService',
        );
        return [];
      }
    } else {
      return [];
    }
  }

  /// Fetches events within a specified price range.
  ///
  /// [rangeFromPrice] is the minimum price (inclusive).
  /// [rangeToPrice] is the maximum price (inclusive).
  ///
  /// Returns a list of [Event] objects that fall within the specified price range.
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
      endpoint: '/events-by-price-range',
      method: 'GET',
      queryParams: {
        'start_price': rangeFromPrice.toString(),
        'end_price': rangeToPrice.toString(),
      },
    );

    if (response.statusCode == 200) {
      try {
        Logger.debug('Raw response body: ${response.body}', 'EventService');
        
        if (response.body.isEmpty) {
          Logger.error('Empty response body', 'EventService');
          return [];
        }

        final dynamic decodedData = jsonDecode(response.body);
        
        if (decodedData == null) {
          Logger.error('Decoded data is null', 'EventService');
          return [];
        }

        if (decodedData is! List) {
          Logger.error('Decoded data is not a List: ${decodedData.runtimeType}', 'EventService');
          return [];
        }

        final List<dynamic> data = decodedData;
        return data.map((json) => Event.fromJson(json as Map<String, dynamic>)).toList();
      } catch (e) {
        Logger.error(
          'Failed to parse JSON response: ${e.toString()}',
          'EventService',
        );
        return [];
      }
    } else {
      Logger.error(
        'API request failed with status code: ${response.statusCode}',
        'EventService',
      );
      return [];
    }
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
      endpoint: '/events-by-date-range',
      method: 'GET',
      queryParams: {'start_date': startDateStr, 'end_date': endDateStr},
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (error) {
        Logger.error(
          'Failed to parse events from API response',
          'EventService',
          error,
        );
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<Event>> getEventsByCategory(int categoryId) async {
    final response = await api.request(
      endpoint: '/events-by-category',
      method: 'GET',
      queryParams: {'category_id': categoryId.toString()},
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        //        return data.map((json) => Event.fromJson(json)).toList();
        final events = data
            .map((json) => Event.fromJson(json as Map<String, dynamic>))
            .toList();
        return events;
      } catch (error) {
        Logger.error(
          'Failed to parse events from API response',
          'EventService',
          error,
        );
        return [];
      }
    } else {
      return [];
    }
  }
}
