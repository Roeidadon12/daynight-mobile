import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../shared/primary_button.dart';

class NewEventStep2 extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final Function(String, dynamic) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const NewEventStep2({
    super.key,
    required this.eventData,
    required this.onDataChanged,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<NewEventStep2> createState() => _NewEventStep2State();
}

class _NewEventStep2State extends State<NewEventStep2> {
  final _formKey = GlobalKey<FormState>();
  final _capacityController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  
  String? _selectedImage;
  bool _isPublic = true;
  bool _allowRegistration = true;
  bool _sendReminders = true;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if any
    _capacityController.text = widget.eventData['capacity']?.toString() ?? '';
    _additionalInfoController.text = widget.eventData['additionalInfo'] ?? '';
    _selectedImage = widget.eventData['image'];
    _isPublic = widget.eventData['isPublic'] ?? true;
    _allowRegistration = widget.eventData['allowRegistration'] ?? true;
    _sendReminders = widget.eventData['sendReminders'] ?? true;
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _capacityController.text.isNotEmpty;
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      // Save all form data
      widget.onDataChanged('capacity', int.tryParse(_capacityController.text));
      widget.onDataChanged('additionalInfo', _additionalInfoController.text);
      widget.onDataChanged('image', _selectedImage);
      widget.onDataChanged('isPublic', _isPublic);
      widget.onDataChanged('allowRegistration', _allowRegistration);
      widget.onDataChanged('sendReminders', _sendReminders);
      
      widget.onNext();
    }
  }

  void _selectImage() {
    // TODO: Implement image picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          AppLocalizations.of(context).get('select-image'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context).get('image-picker-coming-soon'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context).get('ok'),
              style: TextStyle(color: kBrandPrimary),
            ),
          ),
        ],
      ),
    );
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
                    // Event Image
                    Text(
                      AppLocalizations.of(context).get('event-image'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[600]!),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildImagePlaceholder(),
                                ),
                              )
                            : _buildImagePlaceholder(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Capacity
                    Text(
                      AppLocalizations.of(context).get('event-capacity'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _capacityController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).get('enter-max-attendees'),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.people, color: Colors.white54),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).get('capacity-required');
                        }
                        if (int.tryParse(value) == null) {
                          return AppLocalizations.of(context).get('capacity-must-be-number');
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Additional Information
                    Text(
                      AppLocalizations.of(context).get('additional-information'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _additionalInfoController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).get('enter-additional-info'),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Event Settings
                    Text(
                      AppLocalizations.of(context).get('event-settings'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Public Event Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context).get('public-event'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context).get('public-event-description'),
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        value: _isPublic,
                        onChanged: (bool value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                        activeColor: kBrandPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Allow Registration Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context).get('allow-registration'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context).get('allow-registration-description'),
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        value: _allowRegistration,
                        onChanged: (bool value) {
                          setState(() {
                            _allowRegistration = value;
                          });
                        },
                        activeColor: kBrandPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Send Reminders Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          AppLocalizations.of(context).get('send-reminders'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context).get('send-reminders-description'),
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        value: _sendReminders,
                        onChanged: (bool value) {
                          setState(() {
                            _sendReminders = value;
                          });
                        },
                        activeColor: kBrandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Back Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onPrevious,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(AppLocalizations.of(context).get('back')),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Continue Button
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    onPressed: _saveAndNext,
                    textKey: 'continue',
                    disabled: !_isFormValid(),
                    trailingIcon: Icons.arrow_forward,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          color: Colors.grey[400],
          size: 48,
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).get('tap-to-add-image'),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}