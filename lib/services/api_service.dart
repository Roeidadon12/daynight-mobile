import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../exceptions/api_exceptions.dart';
import '../constants.dart';
import '../utils/logger.dart';

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

  /// Makes an HTTP POST request with multipart/form-data.
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? headers,
  }) async {
    try {
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final url = '$cleanBaseUrl/$cleanEndpoint';
      
      final uri = Uri.parse(url);
      Logger.debug('Making multipart request to: $uri', 'ApiService');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers (excluding Content-Type as it will be set automatically)
      final allHeaders = {...defaultHeaders, ...?headers};
      allHeaders.remove('Content-Type'); // Remove to let http package handle multipart boundary
      request.headers.addAll(allHeaders);
      
      // Add form fields
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      // Add files
      if (files != null) {
        for (final entry in files.entries) {
          final file = entry.value;
          final multipartFile = await http.MultipartFile.fromPath(
            entry.key,
            file.path,
          );
          request.files.add(multipartFile);
        }
      }
      
      // Generate curl command for debugging
      if (kEnableDebugCurlOutput) {
        final curlCommand = _generateMultipartCurlCommand(
          uri: uri,
          headers: allHeaders,
          fields: fields ?? {},
          files: files ?? {},
        );
        stderr.writeln('');
        stderr.writeln('=== COPY THIS MULTIPART CURL COMMAND ===');
        stderr.writeln(curlCommand);
        stderr.writeln('=== END CURL COMMAND ===');
        stderr.writeln('');
      }
      
      // Send request
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == HttpStatus.ok) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        Logger.error('Multipart request failed with status: ${response.statusCode}', 'ApiService');
        Logger.error('Response body: ${response.body}', 'ApiService');
        throw ServerException('Request failed with status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      Logger.error('Socket error in multipart request: $e', 'ApiService');
      rethrow;
    } catch (e) {
      Logger.error('Error making multipart request: $e', 'ApiService');
      rethrow;
    }
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
      Logger.debug('Making request to: $uri', 'ApiService');
      
      // Generate and print curl command if debug is enabled
      if (kEnableDebugCurlOutput) {
        final curlCommand = _generateCurlCommand(
          uri: uri,
          method: method,
          headers: {...defaultHeaders, ...?headers},
          body: body,
        );
        // Output to stderr for clean copy-paste without Flutter prefixes
        stderr.writeln('');
        stderr.writeln('=== COPY THIS CURL COMMAND ===');
        stderr.writeln(curlCommand);
        stderr.writeln('=== END CURL COMMAND ===');
        stderr.writeln('');
      }

      final response = await _executeRequest(
        uri: uri,
        method: method,
        headers: {...defaultHeaders, ...?headers},
        body: body,
      );

      if (response.statusCode == HttpStatus.ok) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        Logger.error('Request failed with status: ${response.statusCode}', 'ApiService');
        throw ServerException('Request failed with status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      Logger.error('Socket error: $e', 'ApiService');
      rethrow;
    } catch (e) {
      Logger.error('Error making request: $e', 'ApiService');
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

  /// Generates a curl command for debugging multipart requests.
  String _generateMultipartCurlCommand({
    required Uri uri,
    required Map<String, String> headers,
    required Map<String, String> fields,
    required Map<String, File> files,
  }) {
    final buffer = StringBuffer();
    buffer.write('curl -X POST');
    
    // Add URL
    buffer.write(' \\\n  "$uri"');
    
    // Add headers
    for (final entry in headers.entries) {
      buffer.write(' \\\n  -H "${entry.key}: ${entry.value}"');
    }
    
    // Add form fields
    for (final entry in fields.entries) {
      buffer.write(' \\\n  -F "${entry.key}=${entry.value}"');
    }
    
    // Add files
    for (final entry in files.entries) {
      buffer.write(' \\\n  -F "${entry.key}=@${entry.value.path}"');
    }
    
    return buffer.toString();
  }

  /// Generates a curl command equivalent to the HTTP request for debugging.
  String _generateCurlCommand({
    required Uri uri,
    required String method,
    required Map<String, String> headers,
    dynamic body,
  }) {
    final buffer = StringBuffer();
    
    // Start with curl command and method
    buffer.write('curl -X $method');
    
    // Add URL
    buffer.write(' \\\n  "$uri"');
    
    // Add headers
    headers.forEach((key, value) {
      buffer.write(' \\\n  -H "$key: $value"');
    });
    
    // Add body if present
    if (body != null) {
      String bodyString;
      if (body is String) {
        bodyString = body;
      } else {
        bodyString = json.encode(body);
      }
      
      // Escape quotes and format JSON nicely
      final escapedBody = bodyString.replaceAll('"', '\\"');
      buffer.write(' \\\n  -d "$escapedBody"');
    }
    
    return buffer.toString();
  }
}
