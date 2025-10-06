import 'package:day_night/app_localizations.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/shared/primary_dropdown_field.dart';
import 'package:day_night/controllers/shared/primary_text_form_field.dart';
import 'package:day_night/models/ticket_item.dart';
import 'package:day_night/models/gender.dart' as gender_model;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ParticipantItem extends StatefulWidget {
  final TicketItem ticket;
  final int participantIndex;
  final String participantKey;
  final Map<String, dynamic> controllers;
  final Map<String, bool> errors;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool isValid;

  const ParticipantItem({
    super.key,
    required this.ticket,
    required this.participantIndex,
    required this.participantKey,
    required this.controllers,
    required this.errors,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.isValid,
  });

  @override
  State<ParticipantItem> createState() => _ParticipantItemState();
}

class _ParticipantItemState extends State<ParticipantItem> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  final ImagePicker _picker = ImagePicker();
  XFile? _idCardImage;
  
  @override
  void initState() {
    super.initState();
    firstNameController = widget.controllers['firstName'] as TextEditingController;
    lastNameController = widget.controllers['lastName'] as TextEditingController;
    
    // Add listeners to rebuild when text changes
    firstNameController.addListener(() => setState(() {}));
    lastNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Remove listeners to prevent memory leaks
    firstNameController.removeListener(() => setState(() {}));
    lastNameController.removeListener(() => setState(() {}));
    super.dispose();
  }

  String get participantName {
    if (firstNameController.text.isEmpty && lastNameController.text.isEmpty) {
      return '';
    }
    final nameParts = [firstNameController.text, lastNameController.text].where((part) => part.isNotEmpty);
    return nameParts.join(' ');
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

  Future<void> _pickIdCardImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      print('Attempting to pick image from: ${source.name}');
      
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
        requestFullMetadata: false, // This can help with performance and privacy
      );
      
      if (pickedFile != null) {
        print('Image picked successfully: ${pickedFile.path}');
        setState(() {
          _idCardImage = pickedFile;
        });
        
        // Store the image path in the controller for parent component access
        if (widget.controllers.containsKey('idCardImage')) {
          (widget.controllers['idCardImage'] as TextEditingController).text = pickedFile.path;
        }
        
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
        print('No image was selected');
      }
    } on PlatformException catch (e) {
      print('PlatformException: $e');
      print('Error code: ${e.code}');
      print('Error message: ${e.message}');
      
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
      print('General error picking image: $e');
      print('Error type: ${e.runtimeType}');
      
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
                      controller: firstNameController,
                      labelKey: 'first-name',
                      keyboardType: TextInputType.name,
                      hasError: widget.errors['firstName'] ?? false,
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
                      controller: lastNameController,
                      labelKey: 'last-name',
                      keyboardType: TextInputType.name,
                      hasError: widget.errors['lastName'] ?? false,
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
                  controller: widget.controllers['phoneNumber'] ?? TextEditingController(),
                  labelKey: 'phone-number',
                  keyboardType: TextInputType.phone,
                ),
              ),              
              if (needsIdNumber(widget.ticket))
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PrimaryTextFormField(
                        controller: widget.controllers['idNumber'] ?? TextEditingController(),
                        labelKey: 'id-number',
                        keyboardType: TextInputType.text,
                        hasError: widget.errors['idNumber'] ?? false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Stack(
                        children: [
                          PrimaryTextFormField(
                            controller: TextEditingController(
                              text: _idCardImage != null 
                                  ? _idCardImage!.name 
                                  : '',
                            ),
                            labelKey: 'id-card-image',
                            readOnly: true,
                            suffixIcon: Icon(
                              _idCardImage != null ? Icons.check_circle : Icons.upload_file,
                              color: _idCardImage != null ? Colors.green : Colors.grey,
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
                    controller: widget.controllers['dateOfBirth'] ?? TextEditingController(),
                    labelKey: 'date-of-birth',
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
                              dialogTheme: DialogThemeData(
                                backgroundColor: Colors.grey[850],
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      
                      if (date != null && context.mounted) {
                        widget.controllers['dateOfBirth'].text = '${date.day}/${date.month}/${date.year}';
                      }
                    },
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                  ),
                ),
              if (needsGender(widget.ticket))
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ValueListenableBuilder<gender_model.Gender?>(
                    valueListenable: widget.controllers['gender'] as ValueNotifier<gender_model.Gender?>,
                    builder: (context, selectedGender, child) {
                      return PrimaryDropdownField<gender_model.Gender>(
                        value: selectedGender,
                        labelKey: 'gender',
                        items: gender_model.Gender.values,
                        getLabel: (gender, context) => gender.getLabel(context),
                        onChanged: (value) {
                          (widget.controllers['gender'] as ValueNotifier<gender_model.Gender?>).value = value;
                        },
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}