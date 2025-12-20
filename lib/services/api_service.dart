import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../exceptions/api_exceptions.dart';

/// Service class for handling HTTP requests.
class ApiService {
  /// Base URL for API requests.
  final String baseUrl;
  
  /// Default timeout duration for requests.
  final Duration timeout;
  
  /// Default headers to be included in all requests.
  final Map<String, String> defaultHeaders;

  ApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    Map<String, String>? defaultHeaders,
  }) : defaultHeaders = defaultHeaders ?? {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

  /// Makes an HTTP GET request.
  Future<Map<String, dynamic>> get(String endpoint) async {
    return request(
      endpoint: endpoint,
      method: 'GET',
    );
  }

  /// Makes an HTTP POST request.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    return request(
      endpoint: endpoint,
      method: 'POST',
      body: body,
    );
  }

  /// Makes an HTTP request with the given parameters.
  Future<Map<String, dynamic>> request({
    required String endpoint,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) async {
    try {
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final url = '$cleanBaseUrl/$cleanEndpoint';
      
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      print('Making request to: $uri');

      final response = await _executeRequest(
        uri: uri,
        method: method,
        headers: {...defaultHeaders, ...?headers},
        body: body,
      );

      if (response.statusCode == HttpStatus.ok) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw ServerException('Request failed with status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Socket error: $e');
      rethrow;
    } catch (e) {
      print('Error making request: $e');
      rethrow;
    }
  }

  /// Executes an HTTP request with the given parameters.
  Future<http.Response> _executeRequest({
    required Uri uri,
    required String method,
    required Map<String, String> headers,
    dynamic body,
  }) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers).timeout(timeout);
      case 'POST':
        return await http.post(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        ).timeout(timeout);
      case 'PUT':
        return await http.put(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        ).timeout(timeout);
      case 'DELETE':
        return await http.delete(uri, headers: headers).timeout(timeout);
      default:
        throw BadRequestException('Unsupported HTTP method: $method');
    }
  }
}
