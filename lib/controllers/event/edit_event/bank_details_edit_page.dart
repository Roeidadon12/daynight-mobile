import 'package:day_night/constants.dart';
import 'package:day_night/models/event_details.dart';
import 'package:day_night/models/events.dart';
import 'package:flutter/material.dart';
import '../../shared/labeled_text_form_field.dart';

class BankDetailsEditSection extends StatefulWidget {
  final OrganizerEvent event;
  final EventEditDetails? initialEventData;
  final Map<String, dynamic> eventData;
  final Function(String, dynamic) onDataChanged;

  const BankDetailsEditSection({
    super.key,
    required this.event,
    this.initialEventData,
    required this.eventData,
    required this.onDataChanged,
  });

  @override
  State<BankDetailsEditSection> createState() => _BankDetailsEditSectionState();
}

class _BankDetailsEditSectionState extends State<BankDetailsEditSection> {
  final TextEditingController _bankNumberController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _bankAccountNumberController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bankNumberController.text = widget.eventData['bankNumber']?.toString() ?? '';
    _branchController.text = widget.eventData['branch']?.toString() ?? '';
    _bankAccountNumberController.text = widget.eventData['bankAccountNumber']?.toString() ?? '';
    _accountHolderNameController.text = widget.eventData['accountHolderName']?.toString() ?? '';
  }

  @override
  void dispose() {
    _bankNumberController.dispose();
    _branchController.dispose();
    _bankAccountNumberController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kMainBackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LabeledTextFormField(
              controller: _bankNumberController,
              titleKey: 'bank-number',
              hintTextKey: 'enter-bank-number',
              errorTextKey: 'bank-number-required',
              isRequired: false,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                widget.onDataChanged('bankNumber', value);
              },
            ),
            const SizedBox(height: 24),
            LabeledTextFormField(
              controller: _branchController,
              titleKey: 'branch',
              hintTextKey: 'enter-branch',
              errorTextKey: 'branch-required',
              isRequired: false,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                widget.onDataChanged('branch', value);
              },
            ),
            const SizedBox(height: 24),
            LabeledTextFormField(
              controller: _bankAccountNumberController,
              titleKey: 'bank-account-number',
              hintTextKey: 'enter-bank-account-number',
              errorTextKey: 'bank-account-number-required',
              isRequired: false,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                widget.onDataChanged('bankAccountNumber', value);
              },
            ),
            const SizedBox(height: 24),
            LabeledTextFormField(
              controller: _accountHolderNameController,
              titleKey: 'account-holder-name',
              hintTextKey: 'enter-account-holder-name',
              errorTextKey: 'account-holder-name-required',
              isRequired: false,
              onChanged: (value) {
                widget.onDataChanged('accountHolderName', value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
