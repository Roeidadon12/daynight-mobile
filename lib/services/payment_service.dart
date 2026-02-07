import 'dart:io';
import 'api_service.dart';
import '../constants.dart';
import '../utils/logger.dart';
import '../utils/api_headers.dart';
import '../models/enums.dart';
import '../models/purchase/payment_service_request.dart';

/// Service class responsible for handling all payment-related API operations.
///
/// This service provides methods to process payments, handle ticket purchases,
/// and manage participant ID verification through file uploads.
class PaymentService {
  /// The API service instance used for making HTTP requests.
  final ApiService api;

  /// Creates a new [PaymentService] instance.
  ///
  /// Initializes the [ApiService] with the base URL from configuration.
  PaymentService() : api = ApiService(baseUrl: kApiBaseUrl);

  /// Processes a payment request with participant data and ID verification files.
  ///
  /// [paymentRequest] contains all the payment information including participant data
  /// and any ID verification images that need to be uploaded.
  ///
  /// Returns the payment response data if successful, null if failed.
  ///
  /// Throws [ServerException] if the request fails with a server error.
  Future<Map<String, dynamic>?> processPayment(PaymentServiceRequest paymentRequest) async {
    try {
      Logger.info('Processing payment for event: ${paymentRequest.eventId}', 'PaymentService');
      
      // Get form data and image files
      final formData = paymentRequest.toFormData();
      final imageFiles = paymentRequest.getImageFiles();
      
      // Filter out null files and convert to required format
      final Map<String, File> validImageFiles = {};
      for (final entry in imageFiles.entries) {
        if (entry.value != null) {
          validImageFiles[entry.key] = entry.value!;
        }
      }
      
      // Convert form data values to strings (required by multipart)
      final Map<String, String> stringFormData = {};
      for (final entry in formData.entries) {
        stringFormData[entry.key] = entry.value.toString();
      }
      
      Map<String, dynamic> response;
      
      if (validImageFiles.isNotEmpty) {
        // Use multipart request for payment with ID verification images
        Logger.info('Payment includes ${validImageFiles.length} ID verification files', 'PaymentService');
        
        response = await api.postMultipart(
          ApiCommands.processPayment.value,
          fields: stringFormData,
          files: validImageFiles,
          headers: await ApiHeaders.buildMultipartHeaders(null, true),
        );
      } else {
        // Use regular JSON request if no images
        Logger.info('Payment without ID verification files', 'PaymentService');
        
        response = await api.request(
          endpoint: ApiCommands.processPayment.value,
          method: 'POST',
          body: formData,
          headers: await ApiHeaders.buildHeader(null, true),
        );
      }

      if (response.containsKey('status') && response['status'] == 'success') {
        Logger.info('Payment processed successfully', 'PaymentService');
        return response;
      } else {
        Logger.warning('Payment processing failed: ${response['message'] ?? 'Unknown error'}', 'PaymentService');
        return null;
      }
      
    } catch (e) {
      Logger.error('Error processing payment: $e', 'PaymentService');
      return null;
    }
  }

  /// Validates payment data before processing.
  ///
  /// [paymentRequest] the payment request to validate
  ///
  /// Returns true if the payment request is valid, false otherwise.
  bool validatePaymentRequest(PaymentServiceRequest paymentRequest) {
    try {
      // Basic validation
      if (paymentRequest.eventId <= 0) {
        Logger.error('Invalid event ID: ${paymentRequest.eventId}', 'PaymentService');
        return false;
      }
      
      if (paymentRequest.total < 0) {
        Logger.error('Invalid total amount: ${paymentRequest.total}', 'PaymentService');
        return false;
      }
      
      if (paymentRequest.quantity <= 0) {
        Logger.error('Invalid quantity: ${paymentRequest.quantity}', 'PaymentService');
        return false;
      }
      
      if (paymentRequest.sellTickets.isEmpty) {
        Logger.error('No tickets in payment request', 'PaymentService');
        return false;
      }
      
      // Validate participant data
      if (paymentRequest.fname.isEmpty || paymentRequest.lname.isEmpty) {
        Logger.error('Missing participant names', 'PaymentService');
        return false;
      }
      
      // Validate that participant data is consistent
      final participantCount = paymentRequest.fname.length;
      if (participantCount != paymentRequest.lname.length ||
          participantCount != paymentRequest.email.length ||
          participantCount != paymentRequest.phone.length) {
        Logger.error('Inconsistent participant data lengths', 'PaymentService');
        return false;
      }
      
      Logger.debug('Payment request validation passed', 'PaymentService');
      return true;
      
    } catch (e) {
      Logger.error('Error validating payment request: $e', 'PaymentService');
      return false;
    }
  }

  /// Gets the total cost breakdown for a payment request.
  ///
  /// [paymentRequest] the payment request to analyze
  ///
  /// Returns a map containing cost breakdown details.
  Map<String, double> getPaymentBreakdown(PaymentServiceRequest paymentRequest) {
    final breakdown = <String, double>{
      'subtotal': paymentRequest.total,
      'processing_fee': paymentRequest.processingFee ?? 0.0,
      'discount': -(paymentRequest.discount ?? 0.0),
    };
    
    // Calculate percentage-based processing fee if specified
    if (paymentRequest.processingFeeType == 'percentage' && 
        paymentRequest.processingFeePercentage != null) {
      breakdown['processing_fee'] = paymentRequest.total * (paymentRequest.processingFeePercentage! / 100);
    }
    
    // Calculate final total
    breakdown['total'] = breakdown.values.reduce((sum, value) => sum + value);
    
    return breakdown;
  }
}