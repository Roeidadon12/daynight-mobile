import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/checkout/participant/participant_info.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';
import 'package:day_night/controllers/checkout/participant/participant_item.dart';
import 'package:day_night/controllers/checkout/checkout_tickets.dart';
import 'package:day_night/controllers/checkout/payment/payment_page.dart';
import 'package:day_night/models/participant_data.dart';
import 'package:day_night/models/ticket_item.dart';
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

  // Store participant data for each participant
  late final List<ParticipantData> _participantsData;
  late final List<(TicketItem, int)>
  _flattenedTickets; // List of (ticket, participantIndex)
  int _expandedIndex = 0; // Track which item is currently expanded

  // Calculate total amount from all tickets
  double get totalAmount {
    return _flattenedTickets.fold(0.0, (sum, ticketItem) {
      final (ticket, _) = ticketItem;
      final price = double.tryParse(ticket.ticket.price ?? '0') ?? 0.0;
      return sum + price;
    });
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

  void _initializeParticipantsData() {
    _participantsData = [];
    for (int i = 0; i < _flattenedTickets.length; i++) {
      final (ticket, _) = _flattenedTickets[i];
      _participantsData.add(ParticipantData(ticketId: ticket.id));
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

  int socialInfoType(TicketItem ticket) {
    bool isRequiredFacebook = widget.orderInfo.eventDetails.eventInformation.isRequiredFacebookUsername == 1;
    bool isRequiredInstagram = widget.orderInfo.eventDetails.eventInformation.isRequiredInstagramUsername == 1;
    bool isRequiredOne = widget.orderInfo.eventDetails.eventInformation.isRequiredFacebookOrInstagram == 1;

    // Return based on requirements:
    // 0 - no social media required
    // 1 - only Facebook required
    // 2 - only Instagram required  
    // 3 - both Facebook and Instagram required
    // 4 - either Facebook or Instagram required (user choice)
    
    // Use pattern matching approach
    switch ((isRequiredFacebook, isRequiredInstagram, isRequiredOne)) {
      case (true, true, _): // Both Facebook and Instagram required
        return 3;
      case (true, false, false): // Only Facebook required
        return 1;
      case (false, true, false): // Only Instagram required
        return 2;
      case (false, false, true): // Either one required (user choice)
        return 4;
      case (false, false, false): // None required
      default:
        return 0;
    }
  }

  /// Callback when participant data changes
  void _onParticipantDataChanged(int index, ParticipantData data) {
    _participantsData[index] = data;
  }

  /// Validates all participants and returns true if all are valid
  bool _validateAllParticipants() {
    bool allValid = true;
    int firstInvalidIndex = -1;

    for (int index = 0; index < _flattenedTickets.length; index++) {
      final (ticket, _) = _flattenedTickets[index];
      final participantData = _participantsData[index];

      // Validate this participant's data
      bool isParticipantValid = _validateSingleParticipant(
        participantData,
        ticket,
      );

      if (!isParticipantValid) {
        allValid = false;
        if (firstInvalidIndex == -1) {
          firstInvalidIndex = index;
        }
      }
    }

    if (!allValid) {
      setState(() {
        _expandedIndex = firstInvalidIndex;
      });
    }

    return allValid;
  }

  /// Validates a single participant's data based on ticket requirements
  bool _validateSingleParticipant(ParticipantData data, TicketItem ticket) {
    data.clearErrors();
    bool isValid = true;

    // Validate first name (required)
    if (data.firstName.isEmpty) {
      data.firstNameError = true;
      isValid = false;
    }

    // Validate last name (required)
    if (data.lastName.isEmpty) {
      data.lastNameError = true;
      isValid = false;
    }

    // Validate phone number (required and format)
    if (data.phoneNumber.isEmpty) {
      data.phoneNumberError = true;
      isValid = false;
    } else {
      // Remove formatting (hyphen) for validation
      String digitsOnly = data.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

      // Validate against the regex pattern: must start with 05 followed by 8 digits
      if (digitsOnly.length != 10 ||
          !RegExp(kPhoneValidationRegex).hasMatch(digitsOnly)) {
        data.phoneNumberError = true;
        isValid = false;
      }
    }

    // Validate ID number if required
    if (needsIdNumber(ticket)) {
      if (data.idNumber.isEmpty) {
        data.idNumberError = true;
        isValid = false;
      } else if (!isValidIsraeliId(data.idNumber)) {
        data.idNumberError = true;
        isValid = false;
      }
      // Check if ID card image is required and missing
      if (data.idCardImagePath == null || data.idCardImagePath!.isEmpty) {
        data.idCardImageError = true;
        isValid = false;
      }
    }

    // Validate date of birth if required
    if (needsDateOfBirth(ticket) && data.dateOfBirth.isEmpty) {
      data.dateOfBirthError = true;
      isValid = false;
    }

    // Validate gender if required
    if (needsGender(ticket) && data.gender == null) {
      data.genderError = true;
      isValid = false;
    }

    // Validate social media fields based on requirements
    int socialType = socialInfoType(ticket);
    switch (socialType) {
      case 1: // Only Facebook required
        if (data.facebookId?.isEmpty ?? true) {
          data.facebookIdError = true;
          isValid = false;
        } else if (!isValidFacebookId(data.facebookId!)) {
          data.facebookIdError = true;
          isValid = false;
        }
        break;
      case 2: // Only Instagram required
        if (data.instagramId?.isEmpty ?? true) {
          data.instagramIdError = true;
          isValid = false;
        } else if (!isValidInstagramId(data.instagramId!)) {
          data.instagramIdError = true;
          isValid = false;
        }
        break;
      case 3: // Both required
        if (data.facebookId?.isEmpty ?? true) {
          data.facebookIdError = true;
          isValid = false;
        } else if (!isValidFacebookId(data.facebookId!)) {
          data.facebookIdError = true;
          isValid = false;
        }
        if (data.instagramId?.isEmpty ?? true) {
          data.instagramIdError = true;
          isValid = false;
        } else if (!isValidInstagramId(data.instagramId!)) {
          data.instagramIdError = true;
          isValid = false;
        }
        break;
      case 4: // Either one required (user choice)
        bool facebookEmpty = data.facebookId?.isEmpty ?? true;
        bool instagramEmpty = data.instagramId?.isEmpty ?? true;
        bool facebookValid = !facebookEmpty && isValidFacebookId(data.facebookId!);
        bool instagramValid = !instagramEmpty && isValidInstagramId(data.instagramId!);
        
        if (facebookEmpty && instagramEmpty) {
          // Neither provided
          data.facebookIdError = true;
          data.instagramIdError = true;
          isValid = false;
        } else {
          // At least one provided, validate the provided ones
          if (!facebookEmpty && !facebookValid) {
            data.facebookIdError = true;
            isValid = false;
          }
          if (!instagramEmpty && !instagramValid) {
            data.instagramIdError = true;
            isValid = false;
          }
        }
        break;
      case 0: // None required
      default:
        // No validation needed
        break;
    }

    return isValid;
  }

  bool isValidIsraeliId(String id) {
    // Trim spaces
    id = id.trim();

    // Basic format check: 5–9 digits only
    final regex = RegExp(r'^\d{5,9}$');
    if (!regex.hasMatch(id)) return false;

    // Pad with leading zeros to ensure 9 digits
    id = id.padLeft(9, '0');

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(id[i]);
      int multiplied = digit * ((i % 2) + 1);
      if (multiplied > 9) multiplied -= 9;
      sum += multiplied;
    }

    // Valid if sum is divisible by 10
    return sum % 10 == 0;
  }

  bool isValidFacebookId(String facebookId) {
    // Basic format check: alphanumeric, 5-50 characters
    final regex = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?facebook\.com\/(?:profile\.php\?id=\d+|[A-Za-z0-9.\-]+)\/?$',
      caseSensitive: false,
    );
    return regex.hasMatch(facebookId);
  }

  bool isValidInstagramId(String instagramId) {
    // Basic format check: alphanumeric, underscores, dots, 1-30 characters
    final regex = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?instagram\.com\/[A-Za-z0-9._]+\/?$',
      caseSensitive: false,
    );
    return regex.hasMatch(instagramId);
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

    // Initialize participant data for all participants
    _initializeParticipantsData();
  }

  @override
  void dispose() {
    // No controllers to dispose - ParticipantItems manage their own
    super.dispose();
  }

  void _handleContinue() {
    // Validate all participants
    bool allValid = _validateAllParticipants();
    participantsInfo.clear();

    if (!allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).get('please-fill-in-all-required-fields'),
          ),
          backgroundColor: kBrandNegativePrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // Save all participant information
      for (int i = 0; i < _participantsData.length; i++) {
        final participantData = _participantsData[i];

        participantsInfo.addParticipant(
          ticketId: participantData.ticketId,
          fullName: participantData.fullName,
          idNumber: participantData.idNumber.isNotEmpty
              ? participantData.idNumber
              : null,
          dateOfBirth: participantData.dateOfBirth.isNotEmpty
              ? participantData.dateOfBirth
              : null,
          phoneNumber: participantData.phoneNumber.isNotEmpty
              ? participantData.phoneNumber
              : null,
          gender: participantData.gender,
        );
      }

      widget.orderInfo.currentBasket.setParticipantsInfo(participantsInfo);

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
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        88,
                      ), // Extra bottom padding for the button
                      itemCount: _flattenedTickets.length,
                      itemBuilder: (context, index) {
                        final (ticket, _) = _flattenedTickets[index];

                        return ParticipantItem(
                          ticket: ticket,
                          participantIndex: index,
                          isExpanded: _expandedIndex == index,
                          orderInfo: widget.orderInfo,
                          onToggleExpand: () {
                            setState(() {
                              if (_expandedIndex == index) {
                                _expandedIndex = -1; // Close current item
                              } else {
                                _expandedIndex = index; // Open clicked item
                              }
                            });
                          },
                          onDataChanged: (data) =>
                              _onParticipantDataChanged(index, data),
                          initialData: _participantsData[index],
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
                        side: BorderSide(color: kBrandPrimary, width: 2),
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
