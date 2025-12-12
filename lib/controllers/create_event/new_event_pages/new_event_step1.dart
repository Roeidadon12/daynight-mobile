import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../constants.dart';
import '../../shared/primary_button.dart';
import '../../../models/category.dart';
import '../../../utils/category_utils.dart';

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
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  Category? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    // Load categories
    _categories = getCategoriesByLanguage();
    
    // Initialize with existing data if any
    _eventNameController.text = widget.eventData['eventName'] ?? '';
    _descriptionController.text = widget.eventData['description'] ?? '';
    _locationController.text = widget.eventData['location'] ?? '';
    
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
    
    _selectedDate = widget.eventData['date'];
    _selectedTime = widget.eventData['time'];
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _eventNameController.text.isNotEmpty &&
           _descriptionController.text.isNotEmpty &&
           _locationController.text.isNotEmpty &&
           _selectedCategory != null &&
           _selectedDate != null &&
           _selectedTime != null;
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      // Save all form data
      widget.onDataChanged('eventName', _eventNameController.text);
      widget.onDataChanged('description', _descriptionController.text);
      widget.onDataChanged('location', _locationController.text);
      widget.onDataChanged('category', _selectedCategory);
      widget.onDataChanged('date', _selectedDate);
      widget.onDataChanged('time', _selectedTime);
      
      widget.onNext();
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 20, minute: 0),
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
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
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
                    // Event Name
                    Text(
                      AppLocalizations.of(context).get('event-name'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _eventNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).get('enter-event-name'),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).get('event-name-required');
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description
                    Text(
                      AppLocalizations.of(context).get('description'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).get('enter-event-description'),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).get('description-required');
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Category
                    Text(
                      AppLocalizations.of(context).get('category'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Category>(
                          value: _selectedCategory,
                          hint: Text(
                            AppLocalizations.of(context).get('select-category'),
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: Colors.grey[800],
                          items: _categories.map((Category category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (Category? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Location
                    Text(
                      AppLocalizations.of(context).get('location'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).get('enter-event-location'),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.location_on, color: Colors.white54),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context).get('location-required');
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Date & Time Row
                    Row(
                      children: [
                        // Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).get('date'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectDate,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.white54),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedDate != null
                                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                            : AppLocalizations.of(context).get('select-date'),
                                        style: TextStyle(
                                          color: _selectedDate != null ? Colors.white : Colors.grey[400],
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
                        
                        // Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).get('time'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectTime,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.white54),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime != null
                                            ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                            : AppLocalizations.of(context).get('select-time'),
                                        style: TextStyle(
                                          color: _selectedTime != null ? Colors.white : Colors.grey[400],
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
              textKey: 'continue',
              disabled: !_isFormValid(),
              trailingIcon: Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }
}
