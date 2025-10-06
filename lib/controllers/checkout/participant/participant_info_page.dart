import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/checkout/participant/participant_info.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/controllers/checkout/participant/participant_item.dart';
import 'package:day_night/controllers/checkout/checkout_tickets.dart';
import 'package:day_night/controllers/checkout/payment/payment_page.dart';
import 'package:day_night/models/ticket_item.dart';
import 'package:day_night/models/gender.dart' as gender_model;
import 'package:flutter/material.dart';

class ParticipantInfoPage extends StatefulWidget {
  final CheckoutTickets orderInfo;

  const ParticipantInfoPage({
    super.key,
    required this.orderInfo,
  });

  @override
  State<ParticipantInfoPage> createState() => _ParticipantInfoPageState();
}

class _ParticipantInfoPageState extends State<ParticipantInfoPage> {
  late final ParticipantInfo participantsInfo;
  final _formKey = GlobalKey<FormState>();
  
  // Map to store controllers for each participant
  final Map<String, Map<String, dynamic>> _participantControllers = {};
  late final List<(TicketItem, int)> _flattenedTickets; // List of (ticket, participantIndex)
  int _expandedIndex = 0; // Track which item is currently expanded
  
  // Calculate total amount from all tickets
  double get totalAmount {
    return _flattenedTickets.fold(0.0, (sum, ticketItem) {
      final (ticket, _) = ticketItem;
      final price = double.tryParse(ticket.ticket.price ?? '0') ?? 0.0;
      return sum + price;
    });
  }

  // Helper to convert TextEditingController to ValueNotifier for gender
  ValueNotifier<gender_model.Gender?> _createGenderNotifier() {
    return ValueNotifier<gender_model.Gender?>(null);
  }
  
  List<(TicketItem, int)> _getFlattenedTickets(List<TicketItem> tickets) {
    final flattened = <(TicketItem, int)>[];
    for (final ticket in tickets) {
      for (int i = 0; i < ticket.quantity; i++) {
        flattened.add((ticket, i));
      }
    }
    return flattened;
  }

  void _initializeControllersForTickets() {
    int participantIndex = 0;
    for (final ticket in participantsInfo.selectedTickets) {
      for (int i = 0; i < ticket.quantity; i++) {
        final participantKey = '${ticket.id}_$participantIndex';
        _participantControllers[participantKey] = {
          'firstName': TextEditingController()..addListener(() {
            setState(() {
              _participantControllers[participantKey]!['firstNameError'] = false;
            });
          }),
          'lastName': TextEditingController()..addListener(() {
            setState(() {
              _participantControllers[participantKey]!['lastNameError'] = false;
            });
          }),
          'phoneNumber': TextEditingController()..addListener(() {
            setState(() {
              _participantControllers[participantKey]!['phoneNumberError'] = false;
            });
          }),
          'idNumber': TextEditingController()..addListener(() {
            setState(() {
              _participantControllers[participantKey]!['idNumberError'] = false;
            });
          }),
          'idCardImage': TextEditingController(),
          'dateOfBirth': TextEditingController()..addListener(() {
            setState(() {
              _participantControllers[participantKey]!['dateOfBirthError'] = false;
            });
          }),
          'gender': _createGenderNotifier(), // Use ValueNotifier for gender
          'firstNameError': false,
          'lastNameError': false,
          'phoneNumberError': false,
          'idNumberError': false,
          'dateOfBirthError': false,
          'genderError': false,
        };
        participantIndex++;
      }
    }
  }

  bool needsIdNumber(TicketItem ticket) {
    return ticket.ticket.requiredIdNumber == 1;
  }

  bool needsDateOfBirth(TicketItem ticket) {
    return ticket.ticket.requiredDob == 1;
  }

  bool needsGender(TicketItem ticket) {
    return ticket.ticket.requiredGender == 1;
  }

  bool _isParticipantValid(String participantKey, TicketItem ticket) {
    final controllers = _participantControllers[participantKey];
    if (controllers == null) return false;

    // Both first and last names are required
    if (controllers['firstName'].text.isEmpty || controllers['lastName'].text.isEmpty) return false;

    // Check ID if required
    if (needsIdNumber(ticket) && controllers['idNumber'].text.isEmpty) return false;

    // Check Date of Birth if required
    if (needsDateOfBirth(ticket) && controllers['dateOfBirth'].text.isEmpty) return false;

    // Check Gender if required
    if (needsGender(ticket) && controllers['gender'] == null) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();
    participantsInfo = ParticipantInfo(   
      selectedTickets: widget.orderInfo.currentBasket.ticketInfo?.tickets ?? [],
      eventDetails: widget.orderInfo.eventDetails,
    );
    
    // Create flattened list of tickets
    _flattenedTickets = _getFlattenedTickets(participantsInfo.selectedTickets);
    
    // Initialize controllers for all participants
    _initializeControllersForTickets();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controllers in _participantControllers.values) {
      controllers['firstName']?.dispose();
      controllers['lastName']?.dispose();
      controllers['phoneNumber']?.dispose();
      controllers['idNumber']?.dispose();
      controllers['idCardImage']?.dispose();
      controllers['dateOfBirth']?.dispose();
      (controllers['gender'] as ValueNotifier<gender_model.Gender?>).dispose();
    }
    super.dispose();
  }

  void _handleContinue() {
    // First check if all participants are valid
    bool allParticipantsValid = true;
    int invalidIndex = -1;

    for (int i = 0; i < _flattenedTickets.length; i++) {
      final (ticket, _) = _flattenedTickets[i];
      final participantKey = '${ticket.id}_$i';
      final controllers = _participantControllers[participantKey]!;
      
      // Reset all error states first
      controllers['firstNameError'] = false;
      controllers['lastNameError'] = false;
      controllers['phoneNumberError'] = false;
      controllers['idNumberError'] = false;
      controllers['dateOfBirthError'] = false;
      controllers['genderError'] = false;

      // Check each field and set error state
      if (controllers['firstName'].text.isEmpty) {
        controllers['firstNameError'] = true;
        allParticipantsValid = false;
      }
      if (controllers['lastName'].text.isEmpty) {
        controllers['lastNameError'] = true;
        allParticipantsValid = false;
      }
      if (needsIdNumber(ticket) && controllers['idNumber'].text.isEmpty) {
        controllers['idNumberError'] = true;
        allParticipantsValid = false;
      }
      if (needsDateOfBirth(ticket) && controllers['dateOfBirth'].text.isEmpty) {
        controllers['dateOfBirthError'] = true;
        allParticipantsValid = false;
      }
      if (needsGender(ticket) && controllers['gender'].value == null) {
        controllers['genderError'] = true;
        allParticipantsValid = false;
      }

      if (!allParticipantsValid) {
        invalidIndex = i;
        break;
      }
    }

    if (!allParticipantsValid) {
      // Show error and expand the invalid participant
      setState(() {
        _expandedIndex = invalidIndex;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).get('please-fill-in-all-required-fields')),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // Save all participant information
      for (final ticketEntry in _participantControllers.entries) {
        final parts = ticketEntry.key.split('_');
        final ticketId = parts[0];
        final controllers = ticketEntry.value;

        // Find the ticket for this participant
        final ticket = participantsInfo.selectedTickets.firstWhere(
          (t) => t.id == ticketId,
        );

        participantsInfo.addParticipant(
          fullName: '${controllers['firstName'].text} ${controllers['lastName'].text}'.trim(),
          idNumber: needsIdNumber(ticket) && controllers['idNumber'].text.isNotEmpty 
            ? controllers['idNumber'].text 
            : null,
          dateOfBirth: needsDateOfBirth(ticket) && controllers['dateOfBirth'].text.isNotEmpty 
            ? controllers['dateOfBirth'].text 
            : null,
          gender: needsGender(ticket) ? (controllers['gender'] as ValueNotifier<gender_model.Gender?>).value : null,
        );
      }
      
      // Navigate to payment page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            orderInfo: widget.orderInfo,
            flattenedTickets: _flattenedTickets,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                CustomAppBar(
                  titleKey: 'buy-tickets',
                  onBackPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88), // Extra bottom padding for the button
                      itemCount: _flattenedTickets.length,
                      itemBuilder: (context, index) {
                        final (ticket, _) = _flattenedTickets[index];
                        final participantKey = '${ticket.id}_$index';

                        return ParticipantItem(
                          ticket: ticket,
                          participantIndex: index,
                          participantKey: participantKey,
                          controllers: _participantControllers[participantKey]!,
                          errors: {
                            'firstName': _participantControllers[participantKey]!['firstNameError'] as bool,
                            'lastName': _participantControllers[participantKey]!['lastNameError'] as bool,
                            'phoneNumber': _participantControllers[participantKey]!['phoneNumberError'] as bool,
                            'idNumber': _participantControllers[participantKey]!['idNumberError'] as bool,
                            'dateOfBirth': _participantControllers[participantKey]!['dateOfBirthError'] as bool,
                            'gender': _participantControllers[participantKey]!['genderError'] as bool,
                          },
                          isExpanded: _expandedIndex == index,
                          onToggleExpand: () {
                            setState(() {
                              if (_expandedIndex == index) {
                                _expandedIndex = -1; // Close current item
                              } else {
                                _expandedIndex = index; // Open clicked item
                              }
                            });
                          },
                          isValid: _isParticipantValid(participantKey, ticket),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kMainBackgroundColor.withAlpha(0),
                      kMainBackgroundColor.withAlpha(204), // 0.8 * 255 = 204
                      kMainBackgroundColor,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandPrimary,
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: kBrandPrimary,
                          width: 2,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '${AppLocalizations.of(context).get('to-payment-of')} ${totalAmount.toStringAsFixed(2)} ₪',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}