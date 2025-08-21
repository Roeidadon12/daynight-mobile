import 'dart:convert';
import 'package:http/http.dart' as http;

/// A standardized API response wrapper that includes status, data, and error information.
class ApiResponse<T> {
  /// The HTTP status code of the response.
  final int statusCode;
  
  /// The parsed response data of type T.
  final T? data;
  
  /// Any error message that occurred during the request.
  final String? error;
  
  /// Additional error details or metadata.
  final Map<String, dynamic>? errorDetails;
  
  /// Whether the request was successful (status code 2xx).
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  ApiResponse({
    required this.statusCode,
    this.data,
    this.error,
    this.errorDetails,
  });

  /// Creates an [ApiResponse] from a successful HTTP response.
  factory ApiResponse.success(int statusCode, T? data) {
    return ApiResponse(
      statusCode: statusCode,
      data: data,
    );
  }

  /// Creates an [ApiResponse] from a failed HTTP response.
  factory ApiResponse.error(
    int statusCode,
    String error, {
    Map<String, dynamic>? errorDetails,
  }) {
    return ApiResponse(
      statusCode: statusCode,
      error: error,
      errorDetails: errorDetails,
    );
  }

  /// Attempts to parse a JSON response body into the specified type T.
  static ApiResponse<T> fromJson<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Check if the response has a data wrapper
        final data = body.containsKey('data') ? body['data'] : body;
        return ApiResponse.success(
          response.statusCode,
          fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResponse.error(
          response.statusCode,
          body['message'] as String? ?? 'Unknown error',
          errorDetails: body['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        response.statusCode,
        'Failed to parse response: $e',
      );
    }
  }

  /// Attempts to parse a JSON response body into a List of the specified type T.
  static ApiResponse<List<T>> fromJsonList<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final body = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonList;
        if (body is Map<String, dynamic> && body.containsKey('data')) {
          jsonList = body['data'] as List<dynamic>;
        } else if (body is List<dynamic>) {
          jsonList = body;
        } else {
          throw FormatException('Unexpected JSON format');
        }

        final data = jsonList
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(response.statusCode, data);
      } else {
        final errorBody = body as Map<String, dynamic>;
        return ApiResponse.error(
          response.statusCode,
          errorBody['message'] as String? ?? 'Unknown error',
          errorDetails: errorBody['errors'] as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        response.statusCode,
        'Failed to parse response: $e',
      );
    }
  }
}
