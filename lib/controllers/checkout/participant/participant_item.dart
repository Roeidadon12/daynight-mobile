import 'package:day_night/app_localizations.dart' as app_l10n;
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/shared/primary_dropdown_field.dart';
import 'package:day_night/controllers/shared/primary_text_form_field.dart';
import 'package:day_night/models/ticket_item.dart';
import 'package:day_night/models/gender.dart' as gender_model;
import 'package:flutter/material.dart';

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
                              '${app_l10n.AppLocalizations.of(context).get('participant')} ${(widget.participantIndex + 1).toString().padLeft(2, '0')}',
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
                      labelText: 'First Name',
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
                      labelText: 'Last Name',
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
                  controller: widget.controllers['id'],
                  labelText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
              ),              
              if (needsIdNumber(widget.ticket))
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: PrimaryTextFormField(
                        controller: widget.controllers['id'],
                        labelText: 'ID Number',
                        keyboardType: TextInputType.text,
                        hasError: widget.errors['id'] ?? false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Stack(
                        children: [
                          PrimaryTextFormField(
                            controller: TextEditingController(),
                            labelText: 'ID Card Image',
                            readOnly: true,
                            suffixIcon: const Icon(
                              Icons.upload_file,
                              color: Colors.grey,
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(32),
                                onTap: () {
                                  // TODO: Implement image picker
                                  print('Upload ID Card image');
                                },
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
                    controller: widget.controllers['dateOfBirth'],
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
                        labelText: 'Gender',
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