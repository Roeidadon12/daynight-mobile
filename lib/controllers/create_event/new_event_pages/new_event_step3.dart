import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../../controllers/user/user_controller.dart';
import '../../../screens/auth/login_screen.dart';
import '../../shared/primary_button.dart';
import '../../shared/labeled_text_form_field.dart';

class NewEventStep3 extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final Function(String, dynamic) onDataChanged;
  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  const NewEventStep3({
    super.key,
    required this.eventData,
    required this.onDataChanged,
    required this.onComplete,
    required this.onPrevious,
  });

  @override
  State<NewEventStep3> createState() => _NewEventStep3State();
}

class _NewEventStep3State extends State<NewEventStep3> {
  final _formKey = GlobalKey<FormState>();
  final _organizerNameController = TextEditingController();
  final _urlSuffixController = TextEditingController();
  final _trackingField1Controller = TextEditingController();
  final _trackingField2Controller = TextEditingController();
  final _trackingField3Controller = TextEditingController();
  final _trackingField4Controller = TextEditingController();
  bool _isPrivateEvent = false;
  bool _termsAccepted = false;
  bool _isUserTrackingExpanded = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize with existing data if any
    _organizerNameController.text = widget.eventData['organizerName'] ?? '';
    _urlSuffixController.text = widget.eventData['urlSuffix'] ?? '';
    _trackingField1Controller.text = widget.eventData['trackingField1'] ?? '';
    _trackingField2Controller.text = widget.eventData['trackingField2'] ?? '';
    _trackingField3Controller.text = widget.eventData['trackingField3'] ?? '';
    _trackingField4Controller.text = widget.eventData['trackingField4'] ?? '';
    _isPrivateEvent = widget.eventData['isPrivateEvent'] ?? false;
    _termsAccepted = widget.eventData['termsAccepted'] ?? false;
    _isUserTrackingExpanded = widget.eventData['isUserTrackingExpanded'] ?? false;
  }

  @override
  void dispose() {
    _organizerNameController.dispose();
    _urlSuffixController.dispose();
    _trackingField1Controller.dispose();
    _trackingField2Controller.dispose();
    _trackingField3Controller.dispose();
    _trackingField4Controller.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _organizerNameController.text.trim().isNotEmpty && _termsAccepted;
  }



  void _saveAndComplete() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      // Check if user is authenticated
      final userController = Provider.of<UserController>(context, listen: false);
      
      if (!userController.isLoggedIn) {
        // User is not authenticated, navigate to login screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        ).then((result) {
          // After returning from login screen, check again if user is logged in
          if (userController.isLoggedIn) {
            _proceedWithEventCreation();
          }
          // If user didn't log in (closed login screen or continued as guest),
          // stay on Step3 - don't proceed
        });
        return;
      }
      
      // User is authenticated, proceed with event creation
      _proceedWithEventCreation();
    }
  }
  
  void _proceedWithEventCreation() {
    // Create final URL by combining domain with suffix
    String finalUrl = 'Daynight.co.il/Event/';
    if (_urlSuffixController.text.isNotEmpty) {
      finalUrl += _urlSuffixController.text;
    }
    
    // Save form data
    widget.onDataChanged('organizerName', _organizerNameController.text);
    widget.onDataChanged('urlSuffix', _urlSuffixController.text);
    widget.onDataChanged('finalUrl', finalUrl);
    widget.onDataChanged('isPrivateEvent', _isPrivateEvent);
    widget.onDataChanged('termsAccepted', _termsAccepted);
    widget.onDataChanged('trackingField1', _trackingField1Controller.text);
    widget.onDataChanged('trackingField2', _trackingField2Controller.text);
    widget.onDataChanged('trackingField3', _trackingField3Controller.text);
    widget.onDataChanged('trackingField4', _trackingField4Controller.text);
    widget.onDataChanged('isUserTrackingExpanded', _isUserTrackingExpanded);
    
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kMainBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Organizer Name
                    LabeledTextFormField(
                      controller: _organizerNameController,
                      titleKey: 'organizer-name',
                      hintTextKey: 'enter-organizer-name',
                      errorTextKey: 'organizer-name-required',
                      isRequired: true,
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // URL Address
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context).get('url-address'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Combined URL Input
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.grey[700]!),
                          ),
                          child: Directionality(
                            textDirection: Directionality.of(context),
                            child: Row(
                              children: [
                                // Editable suffix part (left in LTR, right in RTL)
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(color: Colors.grey[600]!, width: 1),
                                    ),
                                    child: TextFormField(
                                      controller: _urlSuffixController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context).get('your-event-name'),
                                        hintStyle: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 16,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      ),
                                      onChanged: (value) => setState(() {}),
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ),
                                ),
                                // Fixed domain part (right in LTR, left in RTL)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Text(
                                    'Daynight.co.il/Event/',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                      fontFamily: 'monospace',
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Private Event Switch
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context).get('private-event'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context).get('private-event-description'),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      value: _isPrivateEvent,
                      onChanged: (bool value) {
                        setState(() {
                          _isPrivateEvent = value;
                        });
                      },
                      activeThumbColor: kBrandPrimary,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Users Tracking Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isUserTrackingExpanded = !_isUserTrackingExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context).get('users-tracking'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  _isUserTrackingExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isUserTrackingExpanded) ...[
                          const SizedBox(height: 16),
                          LabeledTextFormField(
                            controller: _trackingField1Controller,
                            titleKey: 'tracking-field-1',
                            hintTextKey: 'enter-tracking-field-1',
                            isRequired: false,
                            onChanged: (value) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          LabeledTextFormField(
                            controller: _trackingField2Controller,
                            titleKey: 'tracking-field-2',
                            hintTextKey: 'enter-tracking-field-2',
                            isRequired: false,
                            onChanged: (value) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          LabeledTextFormField(
                            controller: _trackingField3Controller,
                            titleKey: 'tracking-field-3',
                            hintTextKey: 'enter-tracking-field-3',
                            isRequired: false,
                            onChanged: (value) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          LabeledTextFormField(
                            controller: _trackingField4Controller,
                            titleKey: 'tracking-field-4',
                            hintTextKey: 'enter-tracking-field-4',
                            isRequired: false,
                            onChanged: (value) => setState(() {}),
                          ),
                        ],
                      ],
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
          
          // Privacy Policy and EULA Section - Fixed at bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return kBrandPrimary;
                    }
                    return Colors.transparent;
                  }),
                  checkColor: Colors.white,
                  side: BorderSide(color: Colors.grey[600]!),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context).get('i-agree-to-the'),
                          ),
                          TextSpan(
                            text: ' ${AppLocalizations.of(context).get('privacy-policy')}',
                            style: TextStyle(
                              color: kBrandPrimary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' ${AppLocalizations.of(context).get('and')} ',
                          ),
                          TextSpan(
                            text: AppLocalizations.of(context).get('terms-of-service'),
                            style: TextStyle(
                              color: kBrandPrimary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16), 
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: _saveAndComplete,
                textKey: 'create-event',
                disabled: !_isFormValid(),
                trailingIcon: Icons.arrow_forward,
                flexible: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}