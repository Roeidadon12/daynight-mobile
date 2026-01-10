import 'dart:io';
import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/checkout/checkout_tickets.dart';
import 'package:day_night/controllers/shared/gender_expandable_field.dart';
import 'package:day_night/controllers/shared/primary_text_form_field.dart';
import 'package:day_night/models/ticket_item.dart';
import 'package:day_night/models/participant_data.dart';
import 'package:day_night/models/gender.dart' as gender_model;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/logger.dart';

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 10 digits
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }
    
    String formatted = '';
    
    if (digitsOnly.isNotEmpty) {
      // Add first 3 digits
      if (digitsOnly.isNotEmpty) {
        formatted += digitsOnly.substring(0, digitsOnly.length.clamp(0, 3));
      }
      
      // Add hyphen and next 7 digits
      if (digitsOnly.length > 3) {
        formatted += '-${digitsOnly.substring(3)}';
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ParticipantItem extends StatefulWidget {
  final TicketItem ticket;
  final int participantIndex;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final Function(ParticipantData) onDataChanged;
  final ParticipantData? initialData;
  final CheckoutTickets orderInfo;  

  const ParticipantItem({
    super.key,
    required this.ticket,
    required this.participantIndex,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onDataChanged,
    required this.orderInfo,
    this.initialData,
  });

  @override
  State<ParticipantItem> createState() => _ParticipantItemState();
}

class _ParticipantItemState extends State<ParticipantItem> {
  late final ParticipantData _participantData;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _idNumberController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _facebookIdController;
  late final TextEditingController _instagramIdController;
  late final ValueNotifier<gender_model.Gender?> _genderNotifier;
  final ImagePicker _picker = ImagePicker();
  XFile? _idCardImage;
  
  String _getImageDisplayName() {
    if (_idCardImage == null) return '';
    
    // Return localized text when image exists
    return AppLocalizations.of(context).get('image-selected');
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 10 digits
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }
    
    String formatted = '';
    
    if (digitsOnly.isNotEmpty) {
      // Add first 3 digits
      if (digitsOnly.isNotEmpty) {
        formatted += digitsOnly.substring(0, digitsOnly.length.clamp(0, 3));
      }
      
      // Add hyphen and next 7 digits
      if (digitsOnly.length > 3) {
        formatted += '-${digitsOnly.substring(3)}';
      }
    }
    
    return formatted;
  }
  
  @override
  void initState() {
    super.initState();
    
    // Initialize participant data with initial data or empty
    _participantData = widget.initialData?.copy() ?? ParticipantData(ticketId: widget.ticket.id);
    
    // Initialize controllers with existing data
    _firstNameController = TextEditingController(text: _participantData.firstName);
    _lastNameController = TextEditingController(text: _participantData.lastName);
    _phoneNumberController = TextEditingController(text: _formatPhoneNumber(_participantData.phoneNumber));
    _idNumberController = TextEditingController(text: _participantData.idNumber);
    _dateOfBirthController = TextEditingController(text: _participantData.dateOfBirth);
    _genderNotifier = ValueNotifier<gender_model.Gender?>(_participantData.gender);
    _facebookIdController = TextEditingController(text: _participantData.facebookId);
    _instagramIdController = TextEditingController(text: _participantData.instagramId);
    
    // Set up image if exists
    if (_participantData.idCardImagePath != null && _participantData.idCardImagePath!.isNotEmpty) {
      _idCardImage = XFile(_participantData.idCardImagePath!);
    }
    
    // Add listeners to update data and notify parent
    _firstNameController.addListener(_onDataChanged);
    _lastNameController.addListener(_onDataChanged);
    _phoneNumberController.addListener(_onDataChanged);
    _idNumberController.addListener(_onDataChanged);
    _dateOfBirthController.addListener(_onDataChanged);
    _genderNotifier.addListener(_onGenderChanged);
    _facebookIdController.addListener(_onDataChanged);
    _instagramIdController.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    // Update participant data
    _participantData.firstName = _firstNameController.text;
    _participantData.lastName = _lastNameController.text;
    _participantData.phoneNumber = _phoneNumberController.text;
    _participantData.idNumber = _idNumberController.text;
    _participantData.dateOfBirth = _dateOfBirthController.text;
    _participantData.facebookId = _facebookIdController.text;
    _participantData.instagramId = _instagramIdController.text;

    // Clear errors when user starts typing and validation passes
    if (_firstNameController.text.isNotEmpty) _participantData.firstNameError = false;
    if (_lastNameController.text.isNotEmpty) _participantData.lastNameError = false;
    
    // Phone number validation - clear error only if format is valid
    if (_phoneNumberController.text.isNotEmpty) {
      // Remove formatting (hyphen) for validation
      String digitsOnly = _phoneNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Only clear error if phone number is valid (correct length and format)
      if (digitsOnly.length == 10 && RegExp(kPhoneValidationRegex).hasMatch(digitsOnly)) {
        _participantData.phoneNumberError = false;
      }
      // If invalid, don't change the error state (let validation method handle it)
    }
    
    if (_idNumberController.text.isNotEmpty) _participantData.idNumberError = false;
    
    // Date of birth validation - clear error only if valid age
    if (_dateOfBirthController.text.isNotEmpty && needsDateOfBirth(widget.ticket)) {
      if (_validateAge(_dateOfBirthController.text)) {
        _participantData.dateOfBirthError = false;
      }
    } else if (_dateOfBirthController.text.isNotEmpty) {
      // If date of birth is not required, just clear error when not empty
      _participantData.dateOfBirthError = false;
    }
    
    if (_facebookIdController.text.isNotEmpty) _participantData.facebookIdError = false;
    if (_instagramIdController.text.isNotEmpty) _participantData.instagramIdError = false;
    
    // Special case: if either Facebook or Instagram is required (case 4) and user fills one, clear both errors
    if (socialInfoType(widget.ticket) == 4) {
      if (_facebookIdController.text.isNotEmpty || _instagramIdController.text.isNotEmpty) {
        _participantData.facebookIdError = false;
        _participantData.instagramIdError = false;
      }
    }
    
    // Notify parent about data changes
    widget.onDataChanged(_participantData);
    
    // Trigger rebuild
    setState(() {});
  }

  void _onGenderChanged() {
    // Update participant data
    _participantData.gender = _genderNotifier.value;
    
    // Clear gender error if a value is selected
    if (_genderNotifier.value != null) {
      _participantData.genderError = false;
    }
    
    // Notify parent about data changes
    widget.onDataChanged(_participantData);
    
    // Trigger rebuild
    setState(() {});
  }

  @override
  void dispose() {
    // Remove listeners and dispose controllers
    _firstNameController.removeListener(_onDataChanged);
    _lastNameController.removeListener(_onDataChanged);
    _phoneNumberController.removeListener(_onDataChanged);
    _idNumberController.removeListener(_onDataChanged);
    _dateOfBirthController.removeListener(_onDataChanged);
    _genderNotifier.removeListener(_onGenderChanged);
    _facebookIdController.removeListener(_onDataChanged);
    _instagramIdController.removeListener(_onDataChanged);

    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _idNumberController.dispose();
    _dateOfBirthController.dispose();
    _genderNotifier.dispose();
    _facebookIdController.dispose();
    _instagramIdController.dispose();

    super.dispose();
  }

  String get participantName {
    return _participantData.fullName;
  }

  /// Validates this participant's data and returns true if valid
  bool validateParticipant() {
    _participantData.clearErrors();
    bool isValid = true;

    // Validate first name (required)
    if (_participantData.firstName.isEmpty) {
      _participantData.firstNameError = true;
      isValid = false;
    }

    // Validate last name (required)
    if (_participantData.lastName.isEmpty) {
      _participantData.lastNameError = true;
      isValid = false;
    }

    // Validate phone number (required and format)
    if (_participantData.phoneNumber.isEmpty) {
      _participantData.phoneNumberError = true;
      isValid = false;
    } else {
      // Remove formatting (hyphen) for validation
      String digitsOnly = _participantData.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Validate against the regex pattern: must start with 05 followed by 8 digits
      if (digitsOnly.length != 10 || !RegExp(kPhoneValidationRegex).hasMatch(digitsOnly)) {
        _participantData.phoneNumberError = true;
        isValid = false;
      }
    }

    // Validate ID number if required
    if (needsIdNumber(widget.ticket)) {
      if (_participantData.idNumber.isEmpty) {
        _participantData.idNumberError = true;
        isValid = false;
      }
      // Check if ID card image is required and missing
      if (_participantData.idCardImagePath == null || _participantData.idCardImagePath!.isEmpty) {
        _participantData.idCardImageError = true;
        isValid = false;
      }
    }

    // Validate date of birth if required
    if (needsDateOfBirth(widget.ticket)) {
      if (_participantData.dateOfBirth.isEmpty) {
        _participantData.dateOfBirthError = true;
        isValid = false;
      } else {
        // Validate minimum age requirement
        if (!_validateAge(_participantData.dateOfBirth)) {
          _participantData.dateOfBirthError = true;
          isValid = false;
        }
      }
    }

    // Validate gender if required
    if (needsGender(widget.ticket) && _participantData.gender == null) {
      _participantData.genderError = true;
      isValid = false;
    }

    // Validate social media fields based on requirements
    int socialType = socialInfoType(widget.ticket);
    switch (socialType) {
      case 1: // Only Facebook required
        if (_participantData.facebookId?.isEmpty ?? true) {
          _participantData.facebookIdError = true;
          isValid = false;
        }
        break;
      case 2: // Only Instagram required
        if (_participantData.instagramId?.isEmpty ?? true) {
          _participantData.instagramIdError = true;
          isValid = false;
        }
        break;
      case 3: // Both required
        if (_participantData.facebookId?.isEmpty ?? true) {
          _participantData.facebookIdError = true;
          isValid = false;
        }
        if (_participantData.instagramId?.isEmpty ?? true) {
          _participantData.instagramIdError = true;
          isValid = false;
        }
        break;
      case 4: // Either one required (user choice)
        if ((_participantData.facebookId?.isEmpty ?? true) && 
            (_participantData.instagramId?.isEmpty ?? true)) {
          _participantData.facebookIdError = true;
          _participantData.instagramIdError = true;
          isValid = false;
        }
        break;
      case 0: // None required
      default:
        // No validation needed
        break;
    }

    // Notify parent about data changes and trigger rebuild
    widget.onDataChanged(_participantData);
    setState(() {});

    return isValid;
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

  /// Validates if the participant's age meets the minimum age requirement
  /// 
  /// [dateOfBirthString] should be in format "dd/mm/yyyy"
  /// Returns true if age is valid (>= minAge), false otherwise
  bool _validateAge(String dateOfBirthString) {
    try {
      // Parse date from "dd/mm/yyyy" format
      final parts = dateOfBirthString.split('/');
      if (parts.length != 3) return false;
      
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      
      if (day == null || month == null || year == null) return false;
      if (day < 1 || day > 31 || month < 1 || month > 12) return false;
      
      final birthDate = DateTime(year, month, day);
      final now = DateTime.now();
      
      // Calculate age in years
      int age = now.year - birthDate.year;
      
      // Adjust age if birthday hasn't occurred this year yet
      if (now.month < birthDate.month || 
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      
      // Get minimum age requirement from event information
      final minAge = widget.orderInfo.eventDetails.eventInformation.minAge;
      
      return age >= minAge;
    } catch (e) {
      // If there's any error parsing the date, consider it invalid
      return false;
    }
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
    
    // Use a more readable pattern matching approach
    int socialType = -1;
    switch ((isRequiredFacebook, isRequiredInstagram, isRequiredOne)) {
      case (true, true, _): // Both Facebook and Instagram required
        socialType = 3;
      case (true, false, false): // Only Facebook required
        socialType = 1;
      case (false, true, false): // Only Instagram required
        socialType = 2;
      case (false, false, true): // Either one required (user choice)
        socialType = 4;
      case (false, false, false): // None required
      default:
        socialType = 0;
    }

    return socialType;
  }

  Future<void> _pickIdCardImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      Logger.debug('Attempting to pick image from: ${source.name}', 'ParticipantItem');
      
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
        requestFullMetadata: false, // This can help with performance and privacy
      );
      
      if (pickedFile != null) {
        Logger.debug('Image picked successfully: ${pickedFile.path}', 'ParticipantItem');
        setState(() {
          _idCardImage = pickedFile;
          _participantData.idCardImagePath = pickedFile.path;
          _participantData.idCardImageError = false; // Clear error when image is selected
        });
        
        // Notify parent about data changes
        widget.onDataChanged(_participantData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ID card image selected successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        Logger.debug('No image was selected', 'ParticipantItem');
      }
    } on PlatformException catch (e) {
      Logger.error('PlatformException: $e', 'ParticipantItem');
      Logger.error('Error code: ${e.code}', 'ParticipantItem');
      Logger.error('Error message: ${e.message}', 'ParticipantItem');
      
      if (mounted) {
        String errorMessage = 'Failed to access ${source == ImageSource.camera ? 'camera' : 'gallery'}';
        
        // Handle specific platform exceptions
        switch (e.code) {
          case 'photo_access_denied':
            errorMessage = 'Photo library access denied. Please grant permission in Settings.';
            break;
          case 'camera_access_denied':
            errorMessage = 'Camera access denied. Please grant permission in Settings.';
            break;
          case 'invalid_image':
            errorMessage = 'The selected file is not a valid image.';
            break;
          default:
            if (e.message != null) {
              errorMessage = 'Error: ${e.message}';
            }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: kBrandNegativePrimary,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                // This will open app settings on most devices
                // You might want to add app_settings package for better control
              },
            ),
          ),
        );
      }
    } catch (e) {
      Logger.error('General error picking image: $e', 'ParticipantItem');
      Logger.error('Error type: ${e.runtimeType}', 'ParticipantItem');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error occurred: $e'),
            backgroundColor: kBrandNegativePrimary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            AppLocalizations.of(context).get('select-image-source'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show current image if it exists
              if (_idCardImage != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context).get('current-image'),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showFullScreenImage(),
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_idCardImage!.path),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).get('tap-to-view-full-image'),
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white30, height: 1),
                const SizedBox(height: 16),
              ],
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: Text(
                  AppLocalizations.of(context).get('camera'),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  AppLocalizations.of(context).get('gallery'),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullScreenImage() {
    if (_idCardImage == null) return;
    
    Navigator.of(context).pop(); // Close the source dialog first
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Tap to dismiss
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // Image
              Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_idCardImage!.path),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          color: Colors.grey[800],
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Unable to load image',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.black.withAlpha(77),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.onToggleExpand,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context).get('participant')} ${(widget.participantIndex + 1).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(220),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.ticket.name,
                              style: TextStyle(
                                color: Colors.white.withAlpha(220),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          participantName,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    widget.isExpanded 
                      ? Icons.keyboard_arrow_up 
                      : Icons.keyboard_arrow_down,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
            if (widget.isExpanded) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryTextFormField(
                      controller: _firstNameController,
                      labelKey: 'first-name',
                      keyboardType: TextInputType.name,
                      hasError: _participantData.firstNameError,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryTextFormField(
                      controller: _lastNameController,
                      labelKey: 'last-name',
                      keyboardType: TextInputType.name,
                      hasError: _participantData.lastNameError,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: PrimaryTextFormField(
                  controller: _phoneNumberController,
                  labelKey: 'phone-number',
                  keyboardType: TextInputType.phone,
                  hasError: _participantData.phoneNumberError,
                  inputFormatters: [
                    _PhoneNumberFormatter(),
                  ],
                  validator: (value) {
                    // We handle validation manually, so always return null here
                    return null;
                  },
                ),
              ),              
              if (needsIdNumber(widget.ticket))
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PrimaryTextFormField(
                        controller: _idNumberController,
                        labelKey: 'id-number',
                        keyboardType: TextInputType.text,
                        hasError: _participantData.idNumberError,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Stack(
                        children: [
                          PrimaryTextFormField(
                            controller: TextEditingController(
                              text: _getImageDisplayName(),
                            ),
                            labelKey: 'id-card-image',
                            readOnly: true,
                            hasError: _participantData.idCardImageError,
                            validator: (value) {
                              // We handle validation manually, so always return null here
                              return null;
                            },
                            suffixIcon: Icon(
                              _idCardImage != null ? Icons.check_circle : Icons.upload_file,
                              color: _idCardImage != null ? Colors.green : kBrandPrimary,
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(32),
                                onTap: _pickIdCardImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (needsDateOfBirth(widget.ticket))
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: PrimaryTextFormField(
                    controller: _dateOfBirthController,
                    labelKey: 'date-of-birth',
                    readOnly: true,
                    hasError: _participantData.dateOfBirthError,
                    validator: (value) {
                      // We handle validation manually, so always return null here
                      return null;
                    },
                    onTap: () async {
                      final minAge = widget.orderInfo.eventDetails.eventInformation.minAge;
                      final maxValidDate = DateTime.now().subtract(Duration(days: minAge * 365));
                      
                      final date = await showDatePicker(
                        context: context,
                        initialDate: maxValidDate.subtract(const Duration(days: 365 * 5)), // Start 5 years older than minimum age
                        firstDate: DateTime(1900),
                        lastDate: maxValidDate, // Only allow dates that meet minimum age requirement
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: kBrandPrimary,
                                onPrimary: Colors.white,
                                surface: Colors.grey[900]!,
                                onSurface: Colors.white,
                              ),
                              dialogTheme: DialogThemeData(
                                backgroundColor: Colors.grey[850],
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      
                      if (date != null && context.mounted) {
                        _dateOfBirthController.text = '${date.day}/${date.month}/${date.year}';
                        _participantData.dateOfBirth = _dateOfBirthController.text;
                        
                        // Validate age and clear error only if valid
                        if (needsDateOfBirth(widget.ticket)) {
                          if (_validateAge(_participantData.dateOfBirth)) {
                            _participantData.dateOfBirthError = false;
                          } else {
                            _participantData.dateOfBirthError = true;
                            // Show user-friendly error message
                            final minAge = widget.orderInfo.eventDetails.eventInformation.minAge;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${AppLocalizations.of(context).get('minimum-age-required')}$minAge',
                                ),
                                backgroundColor: kBrandNegativePrimary,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        } else {
                          _participantData.dateOfBirthError = false;
                        }
                        
                        widget.onDataChanged(_participantData);
                        setState(() {});
                      }
                    },
                    suffixIcon: Icon(Icons.calendar_today, color: kBrandPrimary),
                  ),
                ),
              if (needsGender(widget.ticket))
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ValueListenableBuilder<gender_model.Gender?>(
                    valueListenable: _genderNotifier,
                    builder: (context, selectedGender, child) {
                      return GenderExpandableField(
                        labelKey: 'gender',
                        selected: selectedGender,
                        options: gender_model.Gender.values,
                        hasError: _participantData.genderError,
                        onChanged: (value) {
                          _genderNotifier.value = value;
                        },
                      );
                    },
                  ),
                ),
              // Social media fields based on requirements
              ...() {
                final int socialType = socialInfoType(widget.ticket);
                return [
                  if (socialType == 1) // Only Facebook required
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PrimaryTextFormField(
                        controller: _facebookIdController,
                        labelKey: 'facebook-id',
                        keyboardType: TextInputType.text,
                        hasError: _participantData.facebookIdError,
                      ),
                    ),
                  if (socialType == 2) // Only Instagram required
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PrimaryTextFormField(
                        controller: _instagramIdController,
                        labelKey: 'instagram-id',
                        keyboardType: TextInputType.text,
                        hasError: _participantData.instagramIdError,
                      ),
                    ),
                  if (socialType == 3) ...[  // Both required
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PrimaryTextFormField(
                        controller: _facebookIdController,
                        labelKey: 'facebook-id',
                        keyboardType: TextInputType.text,
                        hasError: _participantData.facebookIdError,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PrimaryTextFormField(
                        controller: _instagramIdController,
                        labelKey: 'instagram-id',
                        keyboardType: TextInputType.text,
                        hasError: _participantData.instagramIdError,
                      ),
                    ),
                  ],
                  if (socialType == 4) ...[  // Either one required (user choice)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PrimaryTextFormField(
                        controller: _facebookIdController,
                        labelKey: 'facebook-id',
                        keyboardType: TextInputType.text,
                        hasError: _participantData.facebookIdError,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PrimaryTextFormField(
                        controller: _instagramIdController,
                        labelKey: 'instagram-id',
                        keyboardType: TextInputType.text,
                        hasError: _participantData.instagramIdError,
                      ),
                    ),
                  ],
                ];
              }(),
            
            ],
          ],
        ),
      ),
    );
  }
}