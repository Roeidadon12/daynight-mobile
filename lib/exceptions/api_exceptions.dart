/// Base class for all API-related exceptions in the application.
abstract class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  ApiException(this.message, {this.code, this.details});

  @override
  String toString() => 'ApiException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Thrown when the server returns a 400 Bad Request response.
class BadRequestException extends ApiException {
  BadRequestException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Thrown when the server returns a 401 Unauthorized response.
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Thrown when the server returns a 403 Forbidden response.
class ForbiddenException extends ApiException {
  ForbiddenException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Thrown when the server returns a 404 Not Found response.
class NotFoundException extends ApiException {
  NotFoundException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Thrown when the server returns a 409 Conflict response.
class ConflictException extends ApiException {
  ConflictException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Thrown when the server returns a 500 Internal Server Error response.
class ServerException extends ApiException {
  ServerException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Thrown when there's a network connectivity issue.
class NetworkException extends ApiException {
  NetworkException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Thrown when there's an error parsing the server response.
class ParseException extends ApiException {
  ParseException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Thrown when a request times out.
class TimeoutException extends ApiException {
  TimeoutException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}
