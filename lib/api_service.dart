import 'dart:convert';
import 'package:http/http.dart' as http;
import 'utils/logger.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<http.Response> request({
    required String endpoint,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(uri, headers: headers);
        case 'POST':
          return await http.post(uri, headers: headers, body: jsonEncode(body));
        case 'PUT':
          return await http.put(uri, headers: headers, body: jsonEncode(body));
        case 'DELETE':
          return await http.delete(uri, headers: headers);
        default:
          throw Exception('Unsupported HTTP method');
      }
    } catch (e) {
      Logger.error('API request failed', 'ApiService', e);
      throw Exception('API request error: $e');
    }
  }
}
