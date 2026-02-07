# Multipart Form Data Implementation Guide

## Overview

This guide explains how to use the newly implemented multipart/form-data support in the ApiService for handling file uploads along with form data in HTTP requests.

## New Features

### 1. ApiService.postMultipart()

The `ApiService` now includes a `postMultipart()` method for sending multipart/form-data requests:

```dart
Future<Map<String, dynamic>> postMultipart(
  String endpoint, {
  Map<String, String>? fields,      // Form fields (text data)
  Map<String, File>? files,         // File attachments
  Map<String, String>? headers,     // Additional headers
})
```

### 2. PaymentService

A new `PaymentService` class has been created to handle payment processing with ID verification file uploads:

```dart
Future<Map<String, dynamic>?> processPayment(PaymentServiceRequest paymentRequest)
```

## Usage Examples

### Basic Multipart Request

```dart
import 'dart:io';
import 'package:day_night/services/api_service.dart';

final apiService = ApiService(baseUrl: 'https://api.example.com');

// Send form data with file upload
final response = await apiService.postMultipart(
  '/upload-data',
  fields: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'description': 'Profile update',
  },
  files: {
    'profile_image': File('/path/to/image.jpg'),
    'document': File('/path/to/document.pdf'),
  },
  headers: {
    'Authorization': 'Bearer your-token-here',
  },
);

print('Upload response: $response');
```

### Event Creation with Image

```dart
import 'package:day_night/services/event_service.dart';
import 'package:day_night/models/create_event_data.dart';

final eventService = EventService();

// Event data from the form
final eventData = CreateEventData(
  eventName: 'My Event',
  description: 'Event description',
  startTime: DateTime.now().add(Duration(days: 7)),
  endTime: DateTime.now().add(Duration(days: 7, hours: 3)),
  // ... other fields
);

// Convert to API format with image path
final apiData = eventData.toApiJson({
  'urlSuffix': 'my-event-url',
  'cover_image': '/path/to/event-image.jpg', // Local file path
});

// Create event (automatically uses multipart if image is present)
final eventId = await eventService.createEvent(apiData, {});

if (eventId != null) {
  print('Event created with ID: $eventId');
} else {
  print('Failed to create event');
}
```

### Payment Processing with ID Verification

```dart
import 'dart:io';
import 'package:day_night/services/payment_service.dart';
import 'package:day_night/models/purchase/payment_service_request.dart';
import 'package:day_night/models/ticket_item.dart';

final paymentService = PaymentService();

// Create payment request with participant ID images
final paymentRequest = PaymentServiceRequest.fromAppModels(
  eventId: 123,
  tickets: [
    TicketItem(
      id: 1,
      name: 'General Admission',
      price: 50.0,
      quantity: 2,
    ),
  ],
  purchaserFullName: 'Alice Johnson',
  purchaserEmail: 'alice@example.com',
  purchaserPhone: '1234567890',
  purchaserCountryCode: '+1',
  participants: [
    ParticipantPaymentInfo(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      phone: '0987654321',
      countryCode: '+1',
      idImage: File('/path/to/john-id.jpg'), // ID verification image
    ),
    ParticipantPaymentInfo(
      firstName: 'Jane',
      lastName: 'Smith',
      email: 'jane@example.com',
      phone: '5555555555',
      countryCode: '+1',
      idImage: File('/path/to/jane-id.jpg'), // ID verification image
    ),
  ],
  purchaserIdImage: File('/path/to/alice-id.jpg'), // Purchaser's ID
);

// Validate and process payment
if (paymentService.validatePaymentRequest(paymentRequest)) {
  final result = await paymentService.processPayment(paymentRequest);
  
  if (result != null) {
    print('Payment successful: ${result['payment_id']}');
  } else {
    print('Payment failed');
  }
} else {
  print('Invalid payment request');
}
```

## Debugging Features

### Curl Command Generation

When `kEnableDebugCurlOutput` is true in constants, the system automatically generates equivalent curl commands for debugging:

```bash
curl -X POST \
  "https://api.example.com/payment/process" \
  -H "Authorization: Bearer token" \
  -H "Accept: application/json" \
  -F "event_id=123" \
  -F "total=100.00" \
  -F "fname={\"1\":\"Alice\",\"2\":\"John\"}" \
  -F "1=@/path/to/alice-id.jpg" \
  -F "2=@/path/to/john-id.jpg"
```

### Logging

The implementation includes comprehensive logging:

```dart
Logger.debug('Making multipart request to: $uri', 'ApiService');
Logger.info('Payment includes 2 ID verification files', 'PaymentService');
Logger.error('Multipart request failed with status: 400', 'ApiService');
```

## Technical Implementation Details

### File Handling

- Files are automatically converted to `http.MultipartFile` using `http.MultipartFile.fromPath()`
- Content-Type headers are automatically set by the http package
- File validation is performed to ensure files exist before uploading

### Form Data Processing

- All form fields are converted to strings as required by multipart format
- Special handling for JSON data (like participant arrays) within form fields
- Automatic URL encoding of field values

### Error Handling

- Network errors are properly caught and logged
- File not found errors are handled gracefully
- Server errors include detailed response information for debugging

### Header Management

- Content-Type is automatically managed for multipart requests
- Authentication headers are preserved from default headers
- Custom headers can be added without conflicts

## API Endpoints

The following API endpoints support multipart requests:

- `/event-management/store` - Event creation with image upload
- `/payment/process` - Payment processing with ID verification files

## Best Practices

1. **Always validate file existence** before attempting upload
2. **Use appropriate image compression** to reduce upload time
3. **Include proper error handling** for network failures
4. **Enable debug curl output** during development for troubleshooting
5. **Validate form data** before sending multipart requests

## Error Handling Examples

```dart
try {
  final response = await apiService.postMultipart('/upload', 
    fields: {'name': 'test'},
    files: {'image': File('/path/to/image.jpg')},
  );
  
  // Handle success
  print('Upload successful: ${response['id']}');
  
} on SocketException catch (e) {
  // Handle network errors
  print('Network error: $e');
  
} on ServerException catch (e) {
  // Handle server errors
  print('Server error: $e');
  
} catch (e) {
  // Handle other errors
  print('Unexpected error: $e');
}
```

This implementation provides a robust foundation for handling file uploads and form data in your Flutter application while maintaining proper error handling, debugging capabilities, and code organization.