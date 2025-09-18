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
  BadRequestException(super.message, {super.code, super.details});
}

/// Thrown when the server returns a 401 Unauthorized response.
class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {super.code, super.details});
}

/// Thrown when the server returns a 403 Forbidden response.
class ForbiddenException extends ApiException {
  ForbiddenException(super.message, {super.code, super.details});
}

/// Thrown when the server returns a 404 Not Found response.
class NotFoundException extends ApiException {
  NotFoundException(super.message, {super.code, super.details});
}

/// Thrown when the server returns a 409 Conflict response.
class ConflictException extends ApiException {
  ConflictException(super.message, {super.code, super.details});
}

/// Thrown when the server returns a 500 Internal Server Error response.
class ServerException extends ApiException {
  ServerException(super.message, {super.code, super.details});
}

/// Thrown when there's a network connectivity issue.
class NetworkException extends ApiException {
  NetworkException(super.message, {super.code, super.details});
}

/// Thrown when there's an error parsing the server response.
class ParseException extends ApiException {
  ParseException(super.message, {super.code, super.details});
}

/// Thrown when a request times out.
class TimeoutException extends ApiException {
  TimeoutException(super.message, {super.code, super.details});
}
