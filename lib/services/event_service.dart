
import '../api_service.dart';
import '../constants.dart';
import 'dart:convert';
import '../models/event.dart';
import '../utils/logger.dart';

class EventService {
  final ApiService api;

  EventService() : api = ApiService(baseUrl: kApiBaseUrl);

  Future<List<Event>> getEventsByDate(String type) async {
    final response = await api.request(
      endpoint: '/events-by-date',
      method: 'GET',
      queryParams: {'type': type},
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      } catch (_) {
        return [];
      }
    } else {
      return [];
    }
  }

 Future<List<Event>> getEventsByDateRange(DateTime startDate, DateTime endDate) async {
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
      queryParams: {
        'start_date': startDateStr,
        'end_date': endDateStr,
      },
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromJson(json as Map<String, dynamic>)).toList();
      } catch (error) {
        Logger.error('Failed to parse events from API response', 'EventService', error);
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
        final events = data.map((json) => Event.fromJson(json as Map<String, dynamic>)).toList();
        return events;
      } catch (error) {
        Logger.error('Failed to parse events from API response', 'EventService', error);
        return [];
      }
    } else {
      return [];
    }
  }
}
