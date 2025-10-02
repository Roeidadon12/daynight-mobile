import 'package:day_night/constants.dart';
import 'package:day_night/controllers/checkout/participant/participant_info_controller.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/controllers/checkout/participant/participant_item.dart';
import 'package:day_night/controllers/shared/primary_button.dart';
import 'package:day_night/controllers/shared/primary_dropdown_field.dart';
import 'package:day_night/controllers/checkout/checkout_tickets_controller.dart';
import 'package:day_night/models/ticket_item.dart';
import 'package:flutter/material.dart';

class ParticipantInfoPage extends StatefulWidget {
  final CheckoutTicketsController orderInfo;

  const ParticipantInfoPage({
    super.key,
    required this.orderInfo,
  });

  @override
  State<ParticipantInfoPage> createState() => _ParticipantInfoPageState();
}

class _ParticipantInfoPageState extends State<ParticipantInfoPage> {
  late final ParticipantInfoController participantsInfo;
  final _formKey = GlobalKey<FormState>();
  
  // Map to store controllers for each participant
  final Map<String, Map<String, dynamic>> _participantControllers = {};
  late final List<(TicketItem, int)> _flattenedTickets; // List of (ticket, participantIndex)
  int _expandedIndex = 0; // Track which item is currently expanded

  // Helper to convert TextEditingController to ValueNotifier for gender
  ValueNotifier<Gender?> _createGenderNotifier() {
    return ValueNotifier<Gender?>(null);
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
          'firstName': TextEditingController(),
          'lastName': TextEditingController(),
          'id': TextEditingController(),
          'dateOfBirth': TextEditingController(),
          'gender': _createGenderNotifier(), // Use ValueNotifier for gender
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
    if (needsIdNumber(ticket) && controllers['id'].text.isEmpty) return false;

    // Check Date of Birth if required
    if (needsDateOfBirth(ticket) && controllers['dateOfBirth'].text.isEmpty) return false;

    // Check Gender if required
    if (needsGender(ticket) && controllers['gender'] == null) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();
    participantsInfo = ParticipantInfoController(   
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
      controllers['id']?.dispose();
      controllers['dateOfBirth']?.dispose();
      (controllers['gender'] as ValueNotifier<Gender?>).dispose();
    }
    super.dispose();
  }

  void _handleContinue() {
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
          idNumber: needsIdNumber(ticket) && controllers['id'].text.isNotEmpty 
            ? controllers['id'].text 
            : null,
          dateOfBirth: needsDateOfBirth(ticket) && controllers['dateOfBirth'].text.isNotEmpty 
            ? controllers['dateOfBirth'].text 
            : null,
          gender: needsGender(ticket) ? controllers['gender'] as Gender? : null,
        );
      }
      
      // TODO: Implement navigation to payment page
      // For now, we'll just print the participants info
      print('Successfully collected ${participantsInfo.participants.length} participant details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              titleKey: 'participant-info',
              onBackPressed: () => Navigator.pop(context),
            ),
            Text(
              'Total Participants: ${_flattenedTickets.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _flattenedTickets.length,
                  itemBuilder: (context, index) {
                    final (ticket, _) = _flattenedTickets[index];
                    final participantKey = '${ticket.id}_$index';

                    return ParticipantItem(
                      ticket: ticket,
                      participantIndex: index,
                      participantKey: participantKey,
                      controllers: _participantControllers[participantKey]!,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                onPressed: _handleContinue,
                textKey: 'continue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}