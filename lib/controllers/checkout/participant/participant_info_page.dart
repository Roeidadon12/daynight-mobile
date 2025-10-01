import 'package:day_night/constants.dart';
import 'package:day_night/controllers/checkout/participant/participant_info_controller.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/controllers/shared/primary_button.dart';
import 'package:day_night/controllers/shared/primary_text_form_field.dart';
import 'package:day_night/controllers/checkout/checkout_tickets_controller.dart';
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
  final _participantNameController = TextEditingController();
  final _participantEmailController = TextEditingController();
  final _participantPhoneController = TextEditingController();
  final _participantIdController = TextEditingController();
  final _participantDateOfBirthController = TextEditingController();
  final _participantGenderController = TextEditingController();

  bool get needsIdNumber {
    return widget.orderInfo.currentBasket.ticketInfo?.tickets.any((t) => t.ticket.requiredIdNumber == 1) ?? false;
  }

  bool get needsDateOfBirth {
    return widget.orderInfo.currentBasket.ticketInfo?.tickets.any((t) => t.ticket.requiredDob == 1) ?? false;
  }

  bool get needsGender {
    return widget.orderInfo.currentBasket.ticketInfo?.tickets.any((t) => t.ticket.requiredGender == 1) ?? false;
  }



  @override
  void initState() {
    super.initState();
    participantsInfo = ParticipantInfoController(   
      selectedTickets: widget.orderInfo.currentBasket.ticketInfo?.tickets ?? [],
      eventDetails: widget.orderInfo.eventDetails,
    );
    return;
  }

  @override
  void dispose() {
    _participantNameController.dispose();
    _participantEmailController.dispose();
    _participantPhoneController.dispose();
    _participantIdController.dispose();
    _participantDateOfBirthController.dispose();
    _participantGenderController.dispose();
  
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      participantsInfo.setPurchaserInfo(
        fullName: _participantNameController.text,
        email: _participantEmailController.text,
        phone: _participantPhoneController.text,
        idNumber: _participantIdController.text.isNotEmpty 
          ? _participantIdController.text 
          : null,
      );
      
      // TODO: Navigate to payment or additional participants page
      if (participantsInfo.remainingParticipants > 0 && participantsInfo.needsParticipantInfo) {
        // Navigate to additional participants page
      } else {
        // Navigate to payment page
      }
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
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Purchaser Information Fields
                    PrimaryTextFormField(
                      controller: _participantNameController,
                      labelText: 'Full Name',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 16),
                    PrimaryTextFormField(
                      controller: _participantEmailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    PrimaryTextFormField(
                      controller: _participantPhoneController,
                      labelText: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    if (needsIdNumber)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: PrimaryTextFormField(
                          controller: _participantIdController,
                          labelText: 'ID Number',
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    if (needsDateOfBirth)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: PrimaryTextFormField(
                          controller: _participantDateOfBirthController,
                          labelText: 'Date of Birth',
                          readOnly: true,
                          onTap: () {
                            // TODO: Show date picker
                          },
                          suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                        ),
                      ),
                    if (needsGender)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: PrimaryTextFormField(
                          controller: _participantGenderController,
                          labelText: 'Gender',
                          readOnly: true,
                          onTap: () {
                            // TODO: Show gender selection dialog
                          },
                          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text('You need to provide information for ${participantsInfo.remainingParticipants} more participant(s).'),
                    const SizedBox(height: 16),
                    // Additional participant fields can be added here
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                onPressed: _handleContinue,
                textKey: 'continue',
                trailingIcon: Icons.arrow_forward,
                flexible: false,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}