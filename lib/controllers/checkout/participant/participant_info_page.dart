import 'package:day_night/constants.dart';
import 'package:day_night/controllers/checkout/participant/participant_info_controller.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/app_localizations.dart';
import 'package:day_night/controllers/shared/primary_button.dart';
import 'package:day_night/controllers/shared/primary_text_form_field.dart';
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
          'name': TextEditingController(),
          'id': TextEditingController(),
          'dateOfBirth': TextEditingController(),
          'gender': null, // This will store the Gender value
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
      controllers['name']?.dispose();
      controllers['id']?.dispose();
      controllers['dateOfBirth']?.dispose();
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
          fullName: controllers['name'].text,
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

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.black.withAlpha(77),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${ticket.name} - ${AppLocalizations.of(context).get('participant')} ${(index + 1).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            PrimaryTextFormField(
                              controller: _participantControllers[participantKey]!['name'],
                              labelText: 'Full Name',
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the participant name';
                                }
                                return null;
                              },
                            ),
                            if (needsIdNumber(ticket))
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: PrimaryTextFormField(
                                  controller: _participantControllers[participantKey]!['id'],
                                  labelText: 'ID Number',
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                            if (needsDateOfBirth(ticket))
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: PrimaryTextFormField(
                                  controller: _participantControllers[participantKey]!['dateOfBirth'],
                                  labelText: 'Date of Birth',
                                  readOnly: true,
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.dark(
                                              primary: kBrandPrimary,
                                              onPrimary: Colors.white,
                                              surface: Colors.grey[900]!,
                                              onSurface: Colors.white,
                                            ),
                                            dialogBackgroundColor: Colors.grey[850],
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    
                                    if (date != null) {
                                      setState(() {
                                        _participantControllers[participantKey]!['dateOfBirth'].text = 
                                            '${date.day}/${date.month}/${date.year}';
                                      });
                                    }
                                  },
                                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                                ),
                              ),
                            if (needsGender(ticket))
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: PrimaryDropdownField<Gender>(
                                  labelText: 'Gender',
                                  value: _participantControllers[participantKey]!['gender'],
                                  items: Gender.values,
                                  onChanged: (gender) {
                                    setState(() {
                                      _participantControllers[participantKey]!['gender'] = gender;
                                    });
                                  },
                                  getLabel: (gender, context) => gender.getLabel(context),
                                ),
                              ),
                          ],
                        ),
                      ),
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