import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../shared/primary_button.dart';
import '../../../models/category.dart';
import '../../../models/language.dart';
import '../../../utils/category_utils.dart';
import '../../../utils/language_helper.dart';
import '../../shared/labeled_text_form_field.dart';

class NewEventStep1 extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final Function(String, dynamic) onDataChanged;
  final VoidCallback onNext;

  const NewEventStep1({
    super.key,
    required this.eventData,
    required this.onDataChanged,
    required this.onNext,
  });

  @override
  State<NewEventStep1> createState() => _NewEventStep1State();
}

class _NewEventStep1State extends State<NewEventStep1> {
  final _formKey = GlobalKey<FormState>();
  
  // Supported languages for event creation - derived from global language list
  List<Language> get _supportedLanguages => LanguageHelper.getAllLanguages();
  
  // Get the default language
  Language? get _defaultLanguage {
    try {
      return _supportedLanguages.firstWhere((lang) => lang.isDefault == 1);
    } catch (e) {
      return _supportedLanguages.isNotEmpty ? _supportedLanguages.first : null;
    }
  }
  
  // Map of controllers for each language
  final Map<String, TextEditingController> _eventNameControllers = {};
  
  // Common fields (not language-specific)
  final _locationController = TextEditingController();
  final _minimalAgeController = TextEditingController();
  
  // Map of category selection for each language
  final Map<String, Category?> _selectedCategories = {};
  
  DateTime? _startTime;
  DateTime? _endTime;
  bool _categoryExpanded = false;
  String _selectedTimezone = 'GMT+2 (Israel)';
  bool _timezoneExpanded = false;
  String _selectedCurrency = 'ILS (Israeli Shekel)';
  bool _currencyExpanded = false;
  String _selectedLanguage = 'Hebrew';
  bool _languageExpanded = false;
  late String _selectedLanguageTab; // Language tab for event name/category

  // Map of categories for each language
  Map<String, List<Category>> _categoriesByLanguage = {};
  
  List<String> get _timezones => [
    'GMT+2 (Israel)',
    'GMT-5 (EST)',
    'GMT-8 (PST)',
    'GMT+0 (UTC)',
    'GMT+1 (CET)',
    'GMT+3 (MSK)',
    'GMT+9 (JST)',
    'GMT+8 (CST)',
    'GMT-3 (BRT)',
    'GMT+5:30 (IST)',
  ];
  
  List<String> get _currencies => [
    'ILS (Israeli Shekel)',
    'USD (US Dollar)',
    'EUR (Euro)',
    'GBP (British Pound)',
    'JPY (Japanese Yen)',
    'CAD (Canadian Dollar)',
    'AUD (Australian Dollar)',
    'CHF (Swiss Franc)',
    'CNY (Chinese Yuan)',
    'INR (Indian Rupee)',
  ];
  
  List<String> get _languages => [
    'Hebrew',
    'English',
    'Arabic',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Chinese',
  ];

  @override
  void initState() {
    super.initState();
    // Load categories for all supported languages
    for (final lang in _supportedLanguages) {
      _categoriesByLanguage[lang.code] = getCategoriesByLanguageId(lang.id);
    }
    
    // Initialize selected language tab with default language
    _selectedLanguageTab = _defaultLanguage?.code ?? 'he';
    
    // Initialize controllers and categories for all supported languages
    for (final lang in _supportedLanguages) {
      _eventNameControllers[lang.code] = TextEditingController();
      _selectedCategories[lang.code] = null;
    }
    
    // Initialize with existing data if any
    for (final lang in _supportedLanguages) {
      _eventNameControllers[lang.code]!.text = widget.eventData['${lang.code}_title'] ?? '';
      
      // Add listener to save data when text changes
      _eventNameControllers[lang.code]!.addListener(() {
        widget.onDataChanged('${lang.code}_title', _eventNameControllers[lang.code]!.text);
      });
      
      // Handle existing category data for this language
      final existingCategory = widget.eventData['${lang.code}_category'];
      final existingCategoryId = widget.eventData['${lang.code}_category_id'];
      final langCategories = _categoriesByLanguage[lang.code] ?? [];
      
      if (existingCategoryId != null && langCategories.isNotEmpty) {
        try {
          _selectedCategories[lang.code] = langCategories.firstWhere(
            (cat) => cat.id == existingCategoryId,
          );
        } catch (e) {
          _selectedCategories[lang.code] = null;
        }
      } else if (existingCategory != null && langCategories.isNotEmpty) {
        if (existingCategory is Category) {
          _selectedCategories[lang.code] = existingCategory;
        } else if (existingCategory is int) {
          try {
            _selectedCategories[lang.code] = langCategories.firstWhere(
              (cat) => cat.id == existingCategory,
            );
          } catch (e) {
            _selectedCategories[lang.code] = null;
          }
        } else if (existingCategory is String) {
          try {
            _selectedCategories[lang.code] = langCategories.firstWhere(
              (cat) => cat.slug == existingCategory || cat.name == existingCategory,
            );
          } catch (e) {
            _selectedCategories[lang.code] = null;
          }
        }
      }
    }
    
    _locationController.text = widget.eventData['address'] ?? '';
    _minimalAgeController.text = widget.eventData['min_age']?.toString() ?? '0';
    
    // Add listeners to common fields to save data when they change
    _locationController.addListener(() {
      widget.onDataChanged('address', _locationController.text);
    });
    
    _minimalAgeController.addListener(() {
      widget.onDataChanged('min_age', _minimalAgeController.text.isNotEmpty ? int.tryParse(_minimalAgeController.text) : 0);
    });
    
    // Handle existing category data - find category by ID or slug if it exists (legacy support)
    final existingCategory = widget.eventData['category'];
    final existingCategoryId = widget.eventData['category_id'];
    final currentLangCategories = _categoriesByLanguage[_selectedLanguageTab] ?? [];
    
    if (existingCategoryId != null && currentLangCategories.isNotEmpty) {
      // Prioritize category_id if available (legacy support - set for current language)
      try {
        _selectedCategories[_selectedLanguageTab] ??= currentLangCategories.firstWhere(
          (cat) => cat.id == existingCategoryId,
        );
      } catch (e) {
        // Ignore if not found
      }
    } else if (existingCategory != null && currentLangCategories.isNotEmpty) {
      // Fallback to old category format (legacy support)
      Category? legacyCategory;
      if (existingCategory is Category) {
        legacyCategory = existingCategory;
      } else if (existingCategory is int) {
        try {
          legacyCategory = currentLangCategories.firstWhere(
            (cat) => cat.id == existingCategory,
          );
        } catch (e) {
          // Ignore
        }
      } else if (existingCategory is String) {
        try {
          legacyCategory = currentLangCategories.firstWhere(
            (cat) => cat.slug == existingCategory || cat.name == existingCategory,
          );
        } catch (e) {
          // Ignore
        }
      }
      if (legacyCategory != null) {
        _selectedCategories[_selectedLanguageTab] ??= legacyCategory;
      }
    }
    
    // Handle existing start date/time data
    final existingStartDate = widget.eventData['start_date'];
    final existingStartTime = widget.eventData['start_time'];
    if (existingStartDate != null && existingStartTime != null) {
      try {
        // Parse date (YYYY-MM-DD) and time (HH:mm) to create DateTime
        final dateParts = existingStartDate.toString().split('-');
        final timeParts = existingStartTime.toString().split(':');
        if (dateParts.length == 3 && timeParts.length >= 2) {
          _startTime = DateTime(
            int.parse(dateParts[0]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[2]), // day
            int.parse(timeParts[0]), // hour
            int.parse(timeParts[1]), // minute
          );
        }
      } catch (e) {
        _startTime = null;
      }
    } else {
      _startTime = widget.eventData['startTime']; // fallback to old format
    }
    
    // Handle existing end date/time data
    final existingEndDate = widget.eventData['end_date'];
    final existingEndTime = widget.eventData['end_time'];
    if (existingEndDate != null && existingEndTime != null) {
      try {
        // Parse date (YYYY-MM-DD) and time (HH:mm) to create DateTime
        final dateParts = existingEndDate.toString().split('-');
        final timeParts = existingEndTime.toString().split(':');
        if (dateParts.length == 3 && timeParts.length >= 2) {
          _endTime = DateTime(
            int.parse(dateParts[0]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[2]), // day
            int.parse(timeParts[0]), // hour
            int.parse(timeParts[1]), // minute
          );
        }
      } catch (e) {
        _endTime = null;
      }
    } else {
      _endTime = widget.eventData['endTime']; // fallback to old format
    }
    _selectedTimezone = widget.eventData['timezone'] ?? 'GMT+2 (Israel)';
    _selectedCurrency = widget.eventData['currency'] ?? 'ILS (Israeli Shekel)';
    _selectedLanguage = widget.eventData['language'] ?? 'Hebrew';
    
    // Initialize country from timezone
    _updateCountryFromTimezone();
  }

  @override
  void dispose() {
    // Save current language values before disposing
    _saveCurrentLanguageValues();
    
    // Save common fields
    widget.onDataChanged('address', _locationController.text);
    widget.onDataChanged('min_age', _minimalAgeController.text.isNotEmpty ? int.tryParse(_minimalAgeController.text) : 0);
    
    // Save date/time fields
    if (_startTime != null) {
      widget.onDataChanged('start_date', '${_startTime!.year.toString().padLeft(4, '0')}-${_startTime!.month.toString().padLeft(2, '0')}-${_startTime!.day.toString().padLeft(2, '0')}');
      widget.onDataChanged('start_time', '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}');
    }
    if (_endTime != null) {
      widget.onDataChanged('end_date', '${_endTime!.year.toString().padLeft(4, '0')}-${_endTime!.month.toString().padLeft(2, '0')}-${_endTime!.day.toString().padLeft(2, '0')}');
      widget.onDataChanged('end_time', '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}');
    }
    widget.onDataChanged('timezone', _selectedTimezone);
    _updateCountryFromTimezone();
    widget.onDataChanged('currency', _selectedCurrency);
    widget.onDataChanged('language', _selectedLanguage);
    
    // Dispose all language-specific controllers
    for (final controller in _eventNameControllers.values) {
      controller.dispose();
    }
    _locationController.dispose();
    _minimalAgeController.dispose();
    super.dispose();
  }

  // Helper methods to get current language-specific values
  TextEditingController get _currentEventNameController {
    return _eventNameControllers[_selectedLanguageTab]!;
  }

  Category? get _currentSelectedCategory {
    return _selectedCategories[_selectedLanguageTab];
  }

  set _currentSelectedCategory(Category? category) {
    _selectedCategories[_selectedLanguageTab] = category;
  }

  // Get categories for the currently selected language tab
  List<Category> get _currentCategories {
    return _categoriesByLanguage[_selectedLanguageTab] ?? [];
  }

  // Method to save current language values to eventData
  void _saveCurrentLanguageValues() {
    widget.onDataChanged('${_selectedLanguageTab}_title', _currentEventNameController.text);
    widget.onDataChanged('${_selectedLanguageTab}_category_id', _currentSelectedCategory?.id);
  }

  // Method to switch language tab
  void _switchLanguageTab(String newLanguage) {
    if (_selectedLanguageTab != newLanguage) {
      // Save current language values before switching
      _saveCurrentLanguageValues();
      setState(() {
        _selectedLanguageTab = newLanguage;
      });
    }
  }

  // Helper method to extract country from timezone string
  String _extractCountryFromTimezone(String timezone) {
    // Extract text between parentheses, e.g., "GMT+2 (Israel)" -> "Israel"
    final regex = RegExp(r'\(([^)]+)\)');
    final match = regex.firstMatch(timezone);
    return match?.group(1) ?? '';
  }

  // Helper method to update country field based on timezone
  void _updateCountryFromTimezone() {
    final defaultLangCode = _defaultLanguage?.code ?? 'he';
    final country = _extractCountryFromTimezone(_selectedTimezone);
    widget.onDataChanged('${defaultLangCode}_country', country);
  }

  bool _isFormValid() {
    // Default language fields are mandatory
    final defaultLangCode = _defaultLanguage?.code;
    if (defaultLangCode != null) {
      final defaultNameFilled = _eventNameControllers[defaultLangCode]?.text.isNotEmpty ?? false;
      final defaultCategoryFilled = _selectedCategories[defaultLangCode] != null;
      
      if (!defaultNameFilled || !defaultCategoryFilled) {
        return false;
      }
    }
    
    // Also check that at least one language (any) has both event name and category
    final hasAtLeastOneLanguageFilled = _supportedLanguages.any(
      (lang) => _eventNameControllers[lang.code]!.text.isNotEmpty && _selectedCategories[lang.code] != null,
    );
    
    return hasAtLeastOneLanguageFilled &&
           _locationController.text.isNotEmpty &&
           _startTime != null &&
           _endTime != null;
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      print('===== Step 1: Saving Form Data =====');
      
      // Save all form data for all supported languages
      for (final lang in _supportedLanguages) {
        final title = _eventNameControllers[lang.code]!.text;
        final categoryId = _selectedCategories[lang.code]?.id;
        widget.onDataChanged('${lang.code}_title', title);
        widget.onDataChanged('${lang.code}_category_id', categoryId);
        print('${lang.code}_title: "$title"');
        print('${lang.code}_category_id: $categoryId');
      }
      
      final address = _locationController.text;
      final minAge = _minimalAgeController.text.isNotEmpty ? int.tryParse(_minimalAgeController.text) : 0;
      widget.onDataChanged('address', address);
      widget.onDataChanged('min_age', minAge);
      print('address: "$address"');
      print('min_age: $minAge');
      
      // Save start date and time separately
      if (_startTime != null) {
        final startDate = '${_startTime!.year.toString().padLeft(4, '0')}-${_startTime!.month.toString().padLeft(2, '0')}-${_startTime!.day.toString().padLeft(2, '0')}';
        final startTime = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
        widget.onDataChanged('start_date', startDate);
        widget.onDataChanged('start_time', startTime);
        print('start_date: $startDate');
        print('start_time: $startTime');
      } else {
        widget.onDataChanged('start_date', null);
        widget.onDataChanged('start_time', null);
      }
      
      // Save end date and time separately
      if (_endTime != null) {
        final endDate = '${_endTime!.year.toString().padLeft(4, '0')}-${_endTime!.month.toString().padLeft(2, '0')}-${_endTime!.day.toString().padLeft(2, '0')}';
        final endTime = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
        widget.onDataChanged('end_date', endDate);
        widget.onDataChanged('end_time', endTime);
        print('end_date: $endDate');
        print('end_time: $endTime');
      } else {
        widget.onDataChanged('end_date', null);
        widget.onDataChanged('end_time', null);
      }
      widget.onDataChanged('timezone', _selectedTimezone);
      _updateCountryFromTimezone();
      widget.onDataChanged('currency', _selectedCurrency);
      widget.onDataChanged('language', _selectedLanguage);
      print('timezone: $_selectedTimezone');
      print('currency: $_selectedCurrency');
      print('language: $_selectedLanguage');
      print('=====================================\n');
      
      widget.onNext();
    }
  }

  Future<void> _selectStartTime() async {
    final DateTime now = DateTime.now();
    final DateTime initialDateTime = _startTime ?? now.add(const Duration(days: 1));
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: kBrandPrimary,
              surface: Colors.grey[900]!,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: kBrandPrimary,
                surface: Colors.grey[900]!,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (pickedTime != null) {
        setState(() {
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          // If end time is not set or is before start time, set it to start time + 2 hours
          if (_endTime == null || _endTime!.isBefore(_startTime!)) {
            _endTime = _startTime!.add(const Duration(hours: 2));
          }
        });
        // Save the updated times immediately
        if (_startTime != null) {
          widget.onDataChanged('start_date', '${_startTime!.year.toString().padLeft(4, '0')}-${_startTime!.month.toString().padLeft(2, '0')}-${_startTime!.day.toString().padLeft(2, '0')}');
          widget.onDataChanged('start_time', '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}');
        }
        if (_endTime != null) {
          widget.onDataChanged('end_date', '${_endTime!.year.toString().padLeft(4, '0')}-${_endTime!.month.toString().padLeft(2, '0')}-${_endTime!.day.toString().padLeft(2, '0')}');
          widget.onDataChanged('end_time', '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}');
        }
      }
    }
  }

  Future<void> _selectEndTime() async {
    final DateTime now = DateTime.now();
    final DateTime initialDateTime = _endTime ?? (_startTime?.add(const Duration(hours: 2)) ?? now.add(const Duration(days: 1, hours: 2)));
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: _startTime ?? now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: kBrandPrimary,
              surface: Colors.grey[900]!,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: kBrandPrimary,
                surface: Colors.grey[900]!,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (pickedTime != null) {
        final DateTime newEndTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        // Ensure end time is after start time
        if (_startTime != null && newEndTime.isBefore(_startTime!)) {
          // Show error or adjust automatically
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).get('end-time-must-be-after-start-time')),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        setState(() {
          _endTime = newEndTime;
        });
        // Save the updated end time immediately
        if (_endTime != null) {
          widget.onDataChanged('end_date', '${_endTime!.year.toString().padLeft(4, '0')}-${_endTime!.month.toString().padLeft(2, '0')}-${_endTime!.day.toString().padLeft(2, '0')}');
          widget.onDataChanged('end_time', '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}');
        }
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // Get the datetime format from localization
    final format = AppLocalizations.of(context).get('datetime-format');
    
    // Simple format replacement for dd/MM/yyyy HH:mm
    String formatted = format
        .replaceAll('dd', dateTime.day.toString().padLeft(2, '0'))
        .replaceAll('MM', dateTime.month.toString().padLeft(2, '0'))
        .replaceAll('yyyy', dateTime.year.toString())
        .replaceAll('HH', dateTime.hour.toString().padLeft(2, '0'))
        .replaceAll('mm', dateTime.minute.toString().padLeft(2, '0'));
    
    return formatted;
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
                    // Language Tabs
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hebrew Tab (Default Language - rendered first/underneath)
                        GestureDetector(
                          onTap: () {
                            _switchLanguageTab('he');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                            decoration: BoxDecoration(
                              color: _selectedLanguageTab == 'he' 
                                  ? const Color(0xFF1A1A1A)
                                  : kMainBackgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: _selectedLanguageTab == 'he'
                                      ? kBrandPrimary
                                      : Colors.grey[700]!,
                                  width: 1.5,
                                ),
                                left: BorderSide(
                                  color: _selectedLanguageTab == 'he'
                                      ? kBrandPrimary
                                      : Colors.grey[700]!,
                                  width: 1.5,
                                ),
                                right: BorderSide(
                                  color: _selectedLanguageTab == 'he'
                                      ? kBrandPrimary
                                      : Colors.grey[700]!,
                                  width: 1.5,
                                ),
                                bottom: _selectedLanguageTab == 'he'
                                    ? BorderSide.none
                                    : BorderSide(
                                        color: Colors.grey[700]!,
                                        width: 1.5,
                                      ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🇮🇱',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'עברית',
                                  style: TextStyle(
                                    color: _selectedLanguageTab == 'he'
                                        ? Colors.white
                                        : Colors.grey[500],
                                    fontSize: 16,
                                    fontWeight: _selectedLanguageTab == 'he'
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // English Tab (rendered second/on top)
                        Transform.translate(
                          offset: const Offset(0, 0),
                          child: GestureDetector(
                            onTap: () {
                              _switchLanguageTab('en');
                            },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                            decoration: BoxDecoration(
                              color: _selectedLanguageTab == 'en'
                                  ? const Color(0xFF1A1A1A)
                                  : kMainBackgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: _selectedLanguageTab == 'en'
                                      ? kBrandPrimary
                                      : Colors.grey[700]!,
                                  width: 1.5,
                                ),
                                left: BorderSide(
                                  color: _selectedLanguageTab == 'en'
                                      ? kBrandPrimary
                                      : Colors.grey[700]!,
                                  width: 1.5,
                                ),
                                right: BorderSide(
                                  color: _selectedLanguageTab == 'en'
                                      ? kBrandPrimary
                                      : Colors.grey[700]!,
                                  width: 1.5,
                                ),
                                bottom: _selectedLanguageTab == 'en'
                                    ? BorderSide.none
                                    : BorderSide(
                                        color: Colors.grey[700]!,
                                        width: 1.5,
                                      ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🇬🇧',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'English',
                                  style: TextStyle(
                                    color: _selectedLanguageTab == 'en'
                                        ? Colors.white
                                        : Colors.grey[500],
                                    fontSize: 16,
                                    fontWeight: _selectedLanguageTab == 'en'
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                    
                    // Rectangle container around Event Name and Category
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
                          // Event Name
                          LabeledTextFormField(
                            controller: _currentEventNameController,
                            titleKey: 'event-name',
                            hintTextKey: 'enter-event-name',
                            errorTextKey: 'event-name-required',
                            isRequired: _selectedLanguageTab == _defaultLanguage?.code,
                            onChanged: (value) {
                              _saveCurrentLanguageValues();
                              setState(() {});
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Category Layout (Full Width)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title with required asterisk
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: AppLocalizations.of(context).get('category'),
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
                                  // Category field trigger only (no inline dropdown)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _categoryExpanded = !_categoryExpanded;
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(77),
                                        borderRadius: BorderRadius.circular(32),
                                        border: Border.all(
                                          color: _categoryExpanded ? kBrandPrimary : Colors.grey[800]!,
                                          width: _categoryExpanded ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _currentSelectedCategory?.name ?? 'Select Category',
                                              style: TextStyle(
                                                color: _currentSelectedCategory != null ? Colors.white : Colors.grey[500],
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          AnimatedRotation(
                                            turns: _categoryExpanded ? 0.5 : 0.0,
                                            duration: const Duration(milliseconds: 200),
                                            child: Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.grey[400],
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Full-width Category Dropdown (appears below)
                              if (_categoryExpanded) ...[
                                const SizedBox(height: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: kMainBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: kBrandPrimary,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: _currentCategories.map((category) {
                                      final isSelected = category == _currentSelectedCategory;
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _currentSelectedCategory = category;
                                            _categoryExpanded = false;
                                          });
                                          // Save category immediately
                                          widget.onDataChanged('${_selectedLanguageTab}_category_id', category.id);
                                        },
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            color: isSelected ? kBrandPrimary.withValues(alpha: 0.15) : Colors.transparent,
                                            border: isSelected
                                                ? Border.all(
                                                    color: kBrandPrimary.withValues(alpha: 0.30),
                                                    width: 1,
                                                  )
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  category.name,
                                                  style: TextStyle(
                                                    color: isSelected ? kBrandPrimary : Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 18,
                                                  color: kBrandPrimary,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Location and Minimal Age Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location
                        Expanded(
                          flex: 1,
                          child: LabeledTextFormField(
                            controller: _locationController,
                            titleKey: 'location',
                            hintTextKey: 'enter-event-location',
                            errorTextKey: 'location-required',
                            isRequired: true,
                            suffixIcon: const Icon(Icons.location_on, color: Colors.white54),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Minimal Age
                        Expanded(
                          flex: 1,
                          child: LabeledTextFormField(
                            controller: _minimalAgeController,
                            titleKey: 'minimal-age',
                            hintTextKey: 'enter-minimal-age',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            customValidator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final age = int.tryParse(value);
                                if (age == null) {
                                  return AppLocalizations.of(context).get('invalid-age');
                                }
                                if (age < 0 || age > 120) {
                                  return AppLocalizations.of(context).get('invalid-age');
                                }
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Start Time & End Time Row
                    Row(
                      children: [
                        // Start Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).get('start-time'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectStartTime,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(77),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.grey[800]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      if (_startTime == null) ...[
                                        Icon(Icons.event, color: Colors.white54),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          _startTime != null
                                              ? _formatDateTime(_startTime!)
                                              : AppLocalizations.of(context).get('select-start-time'),
                                          style: TextStyle(
                                            color: _startTime != null ? Colors.white : Colors.grey[400],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // End Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).get('end-time'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectEndTime,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(77),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.grey[800]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      if (_endTime == null) ...[
                                        Icon(Icons.event, color: Colors.white54),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          _endTime != null
                                              ? _formatDateTime(_endTime!)
                                              : AppLocalizations.of(context).get('select-end-time'),
                                          style: TextStyle(
                                            color: _endTime != null ? Colors.white : Colors.grey[400],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Timezone Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).get('event-timezone'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _timezoneExpanded = !_timezoneExpanded;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(77),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: _timezoneExpanded ? kBrandPrimary : Colors.grey[800]!,
                                width: _timezoneExpanded ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.white54, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedTimezone,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: _timezoneExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey[400],
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Timezone Dropdown
                        if (_timezoneExpanded) ...[
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: kMainBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: kBrandPrimary,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _timezones.map((timezone) {
                                final isSelected = timezone == _selectedTimezone;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedTimezone = timezone;
                                      _timezoneExpanded = false;
                                    });
                                    widget.onDataChanged('timezone', _selectedTimezone);
                                    _updateCountryFromTimezone();
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: isSelected ? kBrandPrimary.withValues(alpha: 0.15) : Colors.transparent,
                                      border: isSelected
                                          ? Border.all(
                                              color: kBrandPrimary.withValues(alpha: 0.30),
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            timezone,
                                            style: TextStyle(
                                              color: isSelected ? kBrandPrimary : Colors.white,
                                              fontSize: 16,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 18,
                                            color: kBrandPrimary,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Currency and Language Row
                    Row(
                      children: [
                        // Currency
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).get('event-currency'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currencyExpanded = !_currencyExpanded;
                                    _languageExpanded = false; // Close language dropdown
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(77),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: _currencyExpanded ? kBrandPrimary : Colors.grey[800]!,
                                      width: _currencyExpanded ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.attach_money, color: Colors.white54, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _selectedCurrency.split(' ')[0], // Show only currency code
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: _currencyExpanded ? 0.5 : 0.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey[400],
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Language
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).get('event-language'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _languageExpanded = !_languageExpanded;
                                    _currencyExpanded = false; // Close currency dropdown
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(77),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: _languageExpanded ? kBrandPrimary : Colors.grey[800]!,
                                      width: _languageExpanded ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.language, color: Colors.white54, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _selectedLanguage,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: _languageExpanded ? 0.5 : 0.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey[400],
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Currency Dropdown (full width below the row)
                    if (_currencyExpanded) ...[
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: kMainBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kBrandPrimary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _currencies.map((currency) {
                            final isSelected = currency == _selectedCurrency;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCurrency = currency;
                                  _currencyExpanded = false;
                                });
                                widget.onDataChanged('currency', currency);
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: isSelected ? kBrandPrimary.withValues(alpha: 0.15) : Colors.transparent,
                                  border: isSelected
                                      ? Border.all(
                                          color: kBrandPrimary.withValues(alpha: 0.30),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currency,
                                        style: TextStyle(
                                          color: isSelected ? kBrandPrimary : Colors.white,
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: kBrandPrimary,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    
                    // Language Dropdown (full width below the row)
                    if (_languageExpanded) ...[
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: kMainBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kBrandPrimary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _languages.map((language) {
                            final isSelected = language == _selectedLanguage;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedLanguage = language;
                                  _languageExpanded = false;
                                });
                                widget.onDataChanged('language', language);
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: isSelected ? kBrandPrimary.withValues(alpha: 0.15) : Colors.transparent,
                                  border: isSelected
                                      ? Border.all(
                                          color: kBrandPrimary.withValues(alpha: 0.30),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        language,
                                        style: TextStyle(
                                          color: isSelected ? kBrandPrimary : Colors.white,
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: kBrandPrimary,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Continue Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: _saveAndNext,
                textKey: 'create-event-continue-to-description',
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
