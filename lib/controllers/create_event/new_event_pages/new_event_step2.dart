import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../shared/primary_button.dart';
import '../../shared/rich_text_editor.dart';
import '../../../utils/quill_to_html_converter.dart';
import '../../../utils/logger.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  
  String? _selectedImage;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if any
    _selectedImage = widget.eventData['image'];
    _descriptionController.text = widget.eventData['description'] ?? '';
    
    // Load existing image file if available
    if (_selectedImage != null && _selectedImage!.isNotEmpty) {
      final imageFile = File(_selectedImage!);
      if (imageFile.existsSync()) {
        _selectedImageFile = imageFile;
      }
    }
    
    // Add listener to controller to see when it changes
    _descriptionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _additionalInfoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    final controllerText = _descriptionController.text;
    final isValid = controllerText.trim().isNotEmpty;
    return isValid;
  }

  /// Extract HTML from Quill delta JSON format using flexible converter
  String _extractHtmlFromQuill(dynamic deltaJson) {
    try {
      return QuillToHtmlConverter.convert(deltaJson);
    } catch (e) {
      // Fallback to plain text if HTML conversion fails
      return _extractPlainTextFromQuill(deltaJson);
    }
  }

  /// Extract plain text from Quill delta JSON format
  String _extractPlainTextFromQuill(dynamic deltaJson) {
    try {
      // The deltaJson could be a List directly (not wrapped in a Map with 'ops' key)
      List<dynamic> ops;
      
      if (deltaJson is List) {
        // Direct array format: [{"insert":"text\n"}]
        ops = deltaJson;
      } else if (deltaJson is Map<String, dynamic> && deltaJson.containsKey('ops')) {
        // Standard Delta format: {"ops": [{"insert":"text\n"}]}
        ops = deltaJson['ops'] as List<dynamic>;
      } else {
        Logger.debug('Unexpected JSON structure: $deltaJson', 'QuillParser');
        return '';
      }
      
      StringBuffer plainText = StringBuffer();
      
      for (final op in ops) {
        if (op is Map<String, dynamic> && op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is String) {
            // Remove the trailing newline that Quill adds
            String text = insert;
            if (text.endsWith('\n') && text.length > 1) {
              text = text.substring(0, text.length - 1);
            }
            plainText.write(text);
          }
        }
      }
      
      final result = plainText.toString().trim();
      return result;
      
    } catch (e) {
      // Silently handle parsing errors
    }
    return '';
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      // Save all form data
      widget.onDataChanged('image', _selectedImage);
      
      // Extract both plain text and HTML from rich text editor
      String description = _descriptionController.text;
      String htmlDescription = '';
      
      try {
        // If the text is in JSON format (Quill delta), extract both formats
        final json = jsonDecode(_descriptionController.text);
        description = _extractPlainTextFromQuill(json);
        htmlDescription = _extractHtmlFromQuill(json);
      } catch (e) {
        // If it's not JSON, it's already plain text
        description = _descriptionController.text;
        htmlDescription = _descriptionController.text; // Fallback to plain text
      }

      widget.onDataChanged('description', description);
      widget.onDataChanged('descriptionHtml', htmlDescription); // Store HTML version
      widget.onDataChanged('en_description', description);
      widget.onDataChanged('descriptionRaw', _descriptionController.text); // Keep JSON version for editing
      
      widget.onNext();
    }
  }

  void _selectImage() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          AppLocalizations.of(context).get('select-image'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: Text(
                AppLocalizations.of(context).get('take-photo'),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: Text(
                AppLocalizations.of(context).get('choose-from-gallery'),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context).get('cancel'),
              style: TextStyle(color: kBrandPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _selectedImage = pickedFile.path;
        });
        
        // Save the image path to form data
        widget.onDataChanged('image', pickedFile.path);
        widget.onDataChanged('imageFile', _selectedImageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).get('image-selection-error'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
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
                          child: _selectedImageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImageFile!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildImagePlaceholder(),
                                  ),
                                )
                              : _selectedImage != null
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
                      onChanged: (value) {
                        setState(() {});
                      },
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
        Text(
          AppLocalizations.of(context).get('upload-image'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context).get('image-size-recommendation'),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }


}