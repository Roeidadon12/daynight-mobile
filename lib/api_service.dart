import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'models/api_response.dart';
import 'exceptions/api_exceptions.dart';
import 'utils/logger.dart';

/// Service class for handling HTTP requests with centralized error handling.
class ApiService {
  /// Base URL for all API requests.
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

  /// Makes an HTTP request and returns a typed [ApiResponse].
  ///
  /// Type [T] specifies the expected response data type.
  /// [fromJson] is a function that converts JSON to type [T].
  Future<ApiResponse<T>> requestTyped<T>({
    required String endpoint,
    required String method,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) async {
    try {
      final response = await request(
        endpoint: endpoint,
        method: method,
        headers: headers,
        queryParams: queryParams,
        body: body,
      );

      return ApiResponse.fromJson(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException('Failed to parse response: $e');
    }
  }

  /// Makes an HTTP request and returns a typed [ApiResponse] containing a list.
  ///
  /// Type [T] specifies the expected item type in the list.
  /// [fromJson] is a function that converts JSON to type [T].
  Future<ApiResponse<List<T>>> requestTypedList<T>({
    required String endpoint,
    required String method,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) async {
    try {
      final response = await request(
        endpoint: endpoint,
        method: method,
        headers: headers,
        queryParams: queryParams,
        body: body,
      );

      return ApiResponse.fromJsonList(response, fromJson);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ParseException('Failed to parse response: $e');
    }
  }

  /// Makes a raw HTTP request and handles common error cases.
  ///
  /// This is an internal method used by [requestTyped] and [requestTypedList].
  /// It handles network errors, timeouts, and HTTP error responses.
  Future<http.Response> request({
    required String endpoint,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl$endpoint')
          .replace(queryParameters: queryParams);

      final Map<String, String> mergedHeaders = {
        ...defaultHeaders,
        ...?headers,
      };

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: mergedHeaders)
              .timeout(timeout);
          break;
        case 'POST':
          response = await http
              .post(uri, headers: mergedHeaders, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: mergedHeaders, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: mergedHeaders)
              .timeout(timeout);
          break;
        default:
          throw BadRequestException('Unsupported HTTP method: $method');
      }

      // Log the response for debugging
      Logger.debug(
        'API ${method.toUpperCase()} ${uri.path}: ${response.statusCode}',
        'ApiService',
      );

      // Handle HTTP error responses
      _handleErrorResponse(response);

      return response;
    } on SocketException catch (e) {
      Logger.error('Network error', 'ApiService', e);
      throw NetworkException('No internet connection');
    } on TimeoutException catch (e) {
      Logger.error('Request timeout', 'ApiService', e);
      throw TimeoutException('Request timed out');
    } catch (e) {
      Logger.error('API request failed', 'ApiService', e);
      rethrow;
    }
  }

  /// Handles HTTP error responses by throwing appropriate exceptions.
  void _handleErrorResponse(http.Response response) {
    if (response.statusCode >= 400) {
      final body = _parseErrorBody(response);
      final message = body['message'] as String? ?? 'Unknown error';
      final errorDetails = body['errors'] as Map<String, dynamic>?;

      switch (response.statusCode) {
        case 400:
          throw BadRequestException(message, details: errorDetails);
        case 401:
          throw UnauthorizedException(message, details: errorDetails);
        case 403:
          throw ForbiddenException(message, details: errorDetails);
        case 404:
          throw NotFoundException(message, details: errorDetails);
        case 409:
          throw ConflictException(message, details: errorDetails);
        case 500:
        case 501:
        case 503:
          throw ServerException(message, details: errorDetails);
        default:
          throw ServerException(
            'HTTP Error ${response.statusCode}',
            details: errorDetails,
          );
      }
    }
  }

  /// Attempts to parse error response body as JSON.
  Map<String, dynamic> _parseErrorBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': response.body};
    }
  }
}
