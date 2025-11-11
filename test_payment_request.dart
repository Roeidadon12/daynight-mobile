import 'package:day_night/models/purchase/payment_service_request.dart';
import 'package:day_night/models/ticket_item.dart';
import 'package:day_night/models/ticket.dart';

void main() {
  // Create a sample ticket item for testing
  final sampleTicket = Ticket.fromJson({
    'id': '1',
    'title': 'VIP Ticket',
    'price': '100.00',
    'pricing_type': 'fixed',
    'required_id_number': 1,
    'required_gender': 1,
    'required_dob': 1,
  });

  final ticketItem = TicketItem(
    id: '1',
    ticket: sampleTicket,
    quantity: 2,
  );

  // Create sample participants
  final participants = [
    ParticipantPaymentInfo(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      phone: '1234567890',
      countryCode: '+1',
      gender: 'male',
      dateOfBirth: '1990-01-01',
      idNumber: 'ID123456',
      instagramUsername: '@johndoe',
      facebookUsername: 'johndoe',
    ),
    ParticipantPaymentInfo(
      firstName: 'Jane',
      lastName: 'Smith',
      email: 'jane@example.com',
      phone: '0987654321',
      countryCode: '+1',
      gender: 'female',
      dateOfBirth: '1992-05-15',
      idNumber: null,
      instagramUsername: null,
      facebookUsername: '@janesmith',
    ),
  ];

  // Create payment request using the factory method
  final paymentRequest = PaymentServiceRequest.fromAppModels(
    eventId: 123,
    tickets: [ticketItem],
    purchaserFullName: 'Alice Johnson',
    purchaserEmail: 'alice@example.com',
    purchaserPhone: '5551234567',
    purchaserCountryCode: '+1',
    participants: participants,
    purchaserIdNumber: 'PURCH789',
    purchaserInstagram: '@alicejohnson',
    purchaserFacebook: 'alice.johnson',
    purchaserGender: 'female',
    purchaserDateOfBirth: '1985-03-20',
    processingFee: 5.00,
    processingFeeType: 'fixed',
    discount: 10.0,
  );

  // Print the form data output to see the structure
  print('Payment Service Request Form Data:');
  print('==================================');
  final formData = paymentRequest.toFormData();
  formData.forEach((key, value) {
    print('$key: $value');
  });
}