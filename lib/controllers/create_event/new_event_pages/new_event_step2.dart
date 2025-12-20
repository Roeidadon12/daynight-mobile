import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../shared/primary_button.dart';
import '../../shared/rich_text_editor.dart';

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
  final _descriptionController = TextEditingController();
  
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if any
    _selectedImage = widget.eventData['image'];
    _descriptionController.text = widget.eventData['description'] ?? '';
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _additionalInfoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _descriptionController.text.trim().isNotEmpty;
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      // Save all form data
      widget.onDataChanged('image', _selectedImage);
      widget.onDataChanged('description', _descriptionController.text);
      
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
                      AppLocalizations.of(context).get('create-event-main-image'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: InkWell(
                        onTap: _selectImage,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[700]!, width: 1),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
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
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Event Description
                    Text(
                      AppLocalizations.of(context).get('create-event-description'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Rich Text Editor
                    RichTextEditor(
                      controller: _descriptionController,
                      hintText: AppLocalizations.of(context).get('create-event-description-instructions'),
                      onChanged: (value) => setState(() {}),
                    ),

                  ],
                ),
              ),
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: _saveAndNext,
                textKey: 'create-event-continue-to-advanced-settings',
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

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.file_upload_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'העלה תמונה',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'גודל מומלץ: 1080x1080 פיקסלים, עד 5MB',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }


}