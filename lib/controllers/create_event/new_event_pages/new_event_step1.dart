import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../shared/primary_button.dart';
import '../../../models/category.dart';
import '../../../utils/category_utils.dart';
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
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _minimalAgeController = TextEditingController();
  
  Category? _selectedCategory;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _categoryExpanded = false;
  String _selectedTimezone = 'GMT+2 (Israel)';
  bool _timezoneExpanded = false;
  String _selectedCurrency = 'ILS (Israeli Shekel)';
  bool _currencyExpanded = false;
  String _selectedLanguage = 'Hebrew';
  bool _languageExpanded = false;

  List<Category> _categories = [];
  
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
    // Load categories
    _categories = getCategoriesByLanguage();
    
    // Initialize with existing data if any
    _eventNameController.text = widget.eventData['eventName'] ?? '';
    _locationController.text = widget.eventData['location'] ?? '';
    _minimalAgeController.text = widget.eventData['minimalAge']?.toString() ?? '';
    
    // Handle existing category data - find category by ID or slug if it exists
    final existingCategory = widget.eventData['category'];
    if (existingCategory != null && _categories.isNotEmpty) {
      if (existingCategory is Category) {
        _selectedCategory = existingCategory;
      } else if (existingCategory is int) {
        try {
          _selectedCategory = _categories.firstWhere(
            (cat) => cat.id == existingCategory,
          );
        } catch (e) {
          _selectedCategory = _categories.first;
        }
      } else if (existingCategory is String) {
        try {
          _selectedCategory = _categories.firstWhere(
            (cat) => cat.slug == existingCategory || cat.name == existingCategory,
          );
        } catch (e) {
          _selectedCategory = _categories.first;
        }
      }
    }
    
    _startTime = widget.eventData['startTime'];
    _endTime = widget.eventData['endTime'];
    _selectedTimezone = widget.eventData['timezone'] ?? 'GMT+2 (Israel)';
    _selectedCurrency = widget.eventData['currency'] ?? 'ILS (Israeli Shekel)';
    _selectedLanguage = widget.eventData['language'] ?? 'Hebrew';
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _minimalAgeController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _eventNameController.text.isNotEmpty &&
           _locationController.text.isNotEmpty &&
           _selectedCategory != null &&
           _startTime != null &&
           _endTime != null;
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      // Save all form data
      widget.onDataChanged('eventName', _eventNameController.text);
      widget.onDataChanged('location', _locationController.text);
      widget.onDataChanged('category', _selectedCategory);
      widget.onDataChanged('minimalAge', _minimalAgeController.text.isNotEmpty ? int.tryParse(_minimalAgeController.text) : null);
      widget.onDataChanged('startTime', _startTime);
      widget.onDataChanged('endTime', _endTime);
      widget.onDataChanged('timezone', _selectedTimezone);
      widget.onDataChanged('currency', _selectedCurrency);
      widget.onDataChanged('language', _selectedLanguage);
      
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
                    // Event Name
                    LabeledTextFormField(
                      controller: _eventNameController,
                      titleKey: 'event-name',
                      hintTextKey: 'enter-event-name',
                      errorTextKey: 'event-name-required',
                      isRequired: true,
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Category and Minimal Age Layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category and Minimal Age Input Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Field Label
                            Expanded(
                              flex: 1,
                              child: Column(
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
                                              _selectedCategory?.name ?? 'Select Category',
                                              style: TextStyle(
                                                color: _selectedCategory != null ? Colors.white : Colors.grey[500],
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
                                customValidator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final age = int.tryParse(value);
                                    if (age == null || age < 0 || age > 120) {
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
                        
                        // Full-width Category Dropdown (appears below the row)
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
                              children: _categories.map((category) {
                                final isSelected = category == _selectedCategory;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                      _categoryExpanded = false;
                                    });
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
                    
                    const SizedBox(height: 24),
                    
                    // Location
                    LabeledTextFormField(
                      controller: _locationController,
                      titleKey: 'location',
                      hintTextKey: 'enter-event-location',
                      errorTextKey: 'location-required',
                      isRequired: true,
                      suffixIcon: const Icon(Icons.location_on, color: Colors.white54),
                      onChanged: (value) => setState(() {}),
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
            child: PrimaryButton(
              onPressed: _saveAndNext,
              textKey: 'create-event-continue-to-description',
              disabled: !_isFormValid(),
              trailingIcon: Icons.arrow_forward,
              flexible: false,
            ),
          ),
        ],
      ),
    );
  }
}
