import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../../models/language.dart';
import '../../shared/primary_button.dart';
import '../../../utils/language_helper.dart';
import '../../../utils/quill_to_html_converter.dart';
import '../../../utils/logger.dart';
import '../full_page_description_editor.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  
  // Supported languages for event creation
  List<Language> get _supportedLanguages => LanguageHelper.getAllLanguages();
  
  // Get the default language
  Language? get _defaultLanguage {
    try {
      return _supportedLanguages.firstWhere((lang) => lang.isDefault == 1);
    } catch (e) {
      return _supportedLanguages.isNotEmpty ? _supportedLanguages.first : null;
    }
  }
  
  // Map of description controllers for each language
  final Map<String, TextEditingController> _descriptionControllers = {};
  
  late String _selectedLanguageTab; // Language tab for description
  
  String? _selectedImage;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    
    // Initialize selected language tab with default language
    _selectedLanguageTab = _defaultLanguage?.code ?? 'he';
    
    // Initialize controllers for all supported languages
    for (final lang in _supportedLanguages) {
      _descriptionControllers[lang.code] = TextEditingController();
    }
    
    // Initialize with existing data if any
    _selectedImage = widget.eventData['image'];
    
    // Load description for each language
    for (final lang in _supportedLanguages) {
      // Try to load description from descriptionRaw first (JSON format for editing), 
      // then fallback to description, or start with empty string
      String existingDescription = widget.eventData['${lang.code}_descriptionRaw'] ?? 
                                  widget.eventData['${lang.code}_description'] ?? 
                                  '';
      _descriptionControllers[lang.code]!.text = existingDescription;
      
      print('Loaded description for ${lang.code}: ${existingDescription.length} characters');
      if (existingDescription.isNotEmpty) {
        print('First 100 chars: ${existingDescription.substring(0, existingDescription.length > 100 ? 100 : existingDescription.length)}');
      }
      
      // Add listener to controller to see when it changes
      _descriptionControllers[lang.code]!.addListener(() {
        setState(() {});
      });
    }
    
    // Load existing image file if available
    if (_selectedImage != null && _selectedImage!.isNotEmpty) {
      final imageFile = File(_selectedImage!);
      if (imageFile.existsSync()) {
        _selectedImageFile = imageFile;
      }
    }
  }

  @override
  void dispose() {
    // Save current language description before disposing
    _saveCurrentLanguageDescription();
    
    // Save image data
    if (_selectedImage != null) {
      widget.onDataChanged('image', _selectedImage);
    }
    if (_selectedImageFile != null) {
      widget.onDataChanged('imageFile', _selectedImageFile);
    }
    
    _capacityController.dispose();
    _additionalInfoController.dispose();
    // Dispose all language-specific controllers
    for (final controller in _descriptionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  // Helper method to get current language description controller
  TextEditingController get _currentDescriptionController {
    return _descriptionControllers[_selectedLanguageTab]!;
  }
  
  // Method to switch language tab
  void _switchLanguageTab(String newLanguage) {
    if (_selectedLanguageTab != newLanguage) {
      // Save current description before switching
      _saveCurrentLanguageDescription();
      setState(() {
        _selectedLanguageTab = newLanguage;
      });
    }
  }

  // Method to open full-page description editor
  Future<void> _openFullPageEditor() async {
    // Save current description before opening editor
    _saveCurrentLanguageDescription();
    
    // Get current language info
    final currentLang = _supportedLanguages.firstWhere(
      (lang) => lang.code == _selectedLanguageTab,
      orElse: () => _supportedLanguages.first,
    );

    // Get the current content with formatting
    final currentContent = _currentDescriptionController.text;
    
    print('Opening full-page editor with content length: ${currentContent.length}');
    if (currentContent.isNotEmpty) {
      print('Content preview: ${currentContent.substring(0, currentContent.length > 100 ? 100 : currentContent.length)}...');
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullPageDescriptionEditor(
          initialContent: currentContent,
          languageCode: currentLang.code,
          languageName: currentLang.name,
          onSave: (content) {
            print('Saving content from full-page editor, length: ${content.length}');
            setState(() {
              _currentDescriptionController.text = content;
              _saveCurrentLanguageDescription();
            });
          },
        ),
      ),
    );
  }

  bool _isFormValid() {
    // Only default language description is mandatory, others are optional
    final defaultLangCode = _defaultLanguage?.code;
    if (defaultLangCode != null) {
      final controllerText = _descriptionControllers[defaultLangCode]?.text ?? '';
      
      // Check if there's actual text content (not just empty JSON formatting)
      if (controllerText.isEmpty) {
        return false;
      }
      
      // Try to extract plain text from Quill JSON format
      try {
        final json = jsonDecode(controllerText);
        final plainText = _extractPlainTextFromQuill(json);
        // Check minimum 30 characters requirement
        return plainText.trim().length >= 30;
      } catch (e) {
        // If not JSON, treat as plain text
        // Check minimum 30 characters requirement
        return controllerText.trim().length >= 30;
      }
    }
    
    // If no default language is set, allow form to be valid
    return true;
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

  /// Get a preview of the description for the tappable field
  String _getDescriptionPreview() {
    final controllerText = _currentDescriptionController.text;
    
    if (controllerText.isEmpty) {
      return AppLocalizations.of(context).get('create-event-description-instructions');
    }
    
    try {
      final json = jsonDecode(controllerText);
      final plainText = _extractPlainTextFromQuill(json);
      return plainText.trim().isNotEmpty 
        ? plainText.trim() 
        : AppLocalizations.of(context).get('create-event-description-instructions');
    } catch (e) {
      // If not JSON, treat as plain text
      return controllerText.trim().isNotEmpty 
        ? controllerText.trim() 
        : AppLocalizations.of(context).get('create-event-description-instructions');
    }
  }

  /// Extract plain text from Quill delta JSON format
  // Get character count from current description controller
  int _getCurrentCharacterCount() {
    final controllerText = _currentDescriptionController.text;
    
    if (controllerText.isEmpty) {
      return 0;
    }
    
    try {
      final json = jsonDecode(controllerText);
      final plainText = _extractPlainTextFromQuill(json);
      return plainText.trim().length;
    } catch (e) {
      // If not JSON, treat as plain text
      return controllerText.trim().length;
    }
  }

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

  // Method to save current language description values to eventData
  void _saveCurrentLanguageDescription() {
    String description = _currentDescriptionController.text;
    String htmlDescription = '';
    
    print('Saving description for language: $_selectedLanguageTab');
    print('Raw content length: ${_currentDescriptionController.text.length}');
    
    try {
      // If the text is in JSON format (Quill delta), extract both formats
      final json = jsonDecode(_currentDescriptionController.text);
      description = _extractPlainTextFromQuill(json);
      htmlDescription = _extractHtmlFromQuill(json);
      print('Successfully parsed as Quill JSON - Plain text length: ${description.length}, HTML length: ${htmlDescription.length}');
    } catch (e) {
      // If it's not JSON, it's already plain text
      print('Content is not Quill JSON, treating as plain text: $e');
      description = _currentDescriptionController.text;
      htmlDescription = _currentDescriptionController.text; // Fallback to plain text
    }

    // Save current language-specific description fields
    widget.onDataChanged('${_selectedLanguageTab}_description', description);
    widget.onDataChanged('${_selectedLanguageTab}_descriptionHtml', htmlDescription);
    widget.onDataChanged('${_selectedLanguageTab}_descriptionRaw', _currentDescriptionController.text);
    
    print('Saved description fields for ${_selectedLanguageTab}');
  }
  
  // Method to save all languages description data (for final submission)
  void _saveAllLanguagesDescription() {
    // Save description data for all languages
    for (final lang in _supportedLanguages) {
      String description = _descriptionControllers[lang.code]!.text;
      String htmlDescription = '';
      
      try {
        // If the text is in JSON format (Quill delta), extract both formats
        final json = jsonDecode(_descriptionControllers[lang.code]!.text);
        description = _extractPlainTextFromQuill(json);
        htmlDescription = _extractHtmlFromQuill(json);
      } catch (e) {
        // If it's not JSON, it's already plain text
        description = _descriptionControllers[lang.code]!.text;
        htmlDescription = _descriptionControllers[lang.code]!.text; // Fallback to plain text
      }

      // Save language-specific description fields
      widget.onDataChanged('${lang.code}_description', description);
      widget.onDataChanged('${lang.code}_descriptionHtml', htmlDescription);
      widget.onDataChanged('${lang.code}_descriptionRaw', _descriptionControllers[lang.code]!.text);
      
      print('${lang.code}_description: ${description.length} chars (plain text)');
      print('${lang.code}_descriptionHtml: ${htmlDescription.length} chars (HTML)');
    }
    
    // Debug log to verify all fields are being set
    Logger.debug('Saving description data for ${_supportedLanguages.length} languages', 'NewEventStep2');
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      print('===== Step 2: Saving Form Data =====');
      
      // Save all form data
      widget.onDataChanged('image', _selectedImage);
      print('image: $_selectedImage');
      
      // Save description data for all languages using the helper method
      _saveAllLanguagesDescription();
      
      print('=====================================\n');
      
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
                    
                    // Language Tabs (outside the bordered container)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Hebrew Tab
                          GestureDetector(
                            onTap: () {
                              _switchLanguageTab('he');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _selectedLanguageTab == 'he' 
                                    ? kBrandPrimary
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🇮🇱',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'עברית',
                                    style: TextStyle(
                                      color: _selectedLanguageTab == 'he'
                                          ? Colors.white
                                          : Colors.grey[400],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // English Tab
                          GestureDetector(
                            onTap: () {
                              _switchLanguageTab('en');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _selectedLanguageTab == 'en'
                                    ? kBrandPrimary
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🇬🇧',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'English',
                                    style: TextStyle(
                                      color: _selectedLanguageTab == 'en'
                                          ? Colors.white
                                          : Colors.grey[400],
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Event Description Container
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Description Title
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context).get('create-event-description'),
                                ),
                                if (_selectedLanguageTab == _defaultLanguage?.code)
                                  const TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Tappable Description Field (opens full-page editor)
                          GestureDetector(
                            onTap: _openFullPageEditor,
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                minHeight: 150,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(77),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[700]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit_note,
                                        color: kBrandPrimary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppLocalizations.of(context).get('tap-to-edit'),
                                        style: TextStyle(
                                          color: kBrandPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _getDescriptionPreview(),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _currentDescriptionController.text.isEmpty 
                                        ? Colors.grey[500] 
                                        : Colors.white,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Minimum characters note and character counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Minimum characters note (aligned to start)
                              Text(
                                AppLocalizations.of(context).get('description-minimum-characters'),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              
                              // Character counter (aligned to end)
                              Text(
                                '${_getCurrentCharacterCount()} ${AppLocalizations.of(context).get('characters')}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
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