import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../app_localizations.dart';
import '../../controllers/shared/labeled_text_form_field.dart';
import '../../models/gender.dart' as gender_model;
import 'sms_verification_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCountryCode = '+972'; // Default to Israel
  final List<Map<String, String>> _countryCodes = [
    {'code': '+972', 'name': 'Israel', 'flag': '🇮🇱'},
    {'code': '+1', 'name': 'USA/Canada', 'flag': '🇺🇸'},
    {'code': '+44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '+33', 'name': 'France', 'flag': '🇫🇷'},
    {'code': '+49', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': '+39', 'name': 'Italy', 'flag': '🇮🇹'},
    {'code': '+34', 'name': 'Spain', 'flag': '🇪🇸'},
    {'code': '+31', 'name': 'Netherlands', 'flag': '🇳🇱'},
    {'code': '+41', 'name': 'Switzerland', 'flag': '🇨🇭'},
    {'code': '+43', 'name': 'Austria', 'flag': '🇦🇹'},
    {'code': '+32', 'name': 'Belgium', 'flag': '🇧🇪'},
    {'code': '+46', 'name': 'Sweden', 'flag': '🇸🇪'},
    {'code': '+47', 'name': 'Norway', 'flag': '🇳🇴'},
    {'code': '+45', 'name': 'Denmark', 'flag': '🇩🇰'},
    {'code': '+358', 'name': 'Finland', 'flag': '🇫🇮'},
    {'code': '+351', 'name': 'Portugal', 'flag': '🇵🇹'},
    {'code': '+30', 'name': 'Greece', 'flag': '🇬🇷'},
    {'code': '+90', 'name': 'Turkey', 'flag': '🇹🇷'},
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '+86', 'name': 'China', 'flag': '🇨🇳'},
    {'code': '+81', 'name': 'Japan', 'flag': '🇯🇵'},
    {'code': '+82', 'name': 'South Korea', 'flag': '🇰🇷'},
    {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': '+64', 'name': 'New Zealand', 'flag': '🇳🇿'},
    {'code': '+27', 'name': 'South Africa', 'flag': '🇿🇦'},
    {'code': '+55', 'name': 'Brazil', 'flag': '🇧🇷'},
    {'code': '+52', 'name': 'Mexico', 'flag': '🇲🇽'},
    {'code': '+54', 'name': 'Argentina', 'flag': '🇦🇷'},
    {'code': '+56', 'name': 'Chile', 'flag': '🇨🇱'},
    {'code': '+57', 'name': 'Colombia', 'flag': '🇨🇴'},
    {'code': '+7', 'name': 'Russia', 'flag': '🇷🇺'},
    {'code': '+380', 'name': 'Ukraine', 'flag': '🇺🇦'},
    {'code': '+48', 'name': 'Poland', 'flag': '🇵🇱'},
    {'code': '+420', 'name': 'Czech Republic', 'flag': '🇨🇿'},
    {'code': '+36', 'name': 'Hungary', 'flag': '🇭🇺'},
    {'code': '+40', 'name': 'Romania', 'flag': '🇷🇴'},
    {'code': '+359', 'name': 'Bulgaria', 'flag': '🇧🇬'},
    {'code': '+385', 'name': 'Croatia', 'flag': '🇭🇷'},
    {'code': '+381', 'name': 'Serbia', 'flag': '🇷🇸'},
    {'code': '+62', 'name': 'Indonesia', 'flag': '🇮🇩'},
    {'code': '+60', 'name': 'Malaysia', 'flag': '🇲🇾'},
    {'code': '+65', 'name': 'Singapore', 'flag': '🇸🇬'},
    {'code': '+66', 'name': 'Thailand', 'flag': '🇹🇭'},
    {'code': '+84', 'name': 'Vietnam', 'flag': '🇻🇳'},
    {'code': '+63', 'name': 'Philippines', 'flag': '🇵🇭'},
    {'code': '+20', 'name': 'Egypt', 'flag': '🇪🇬'},
    {'code': '+971', 'name': 'UAE', 'flag': '🇦🇪'},
    {'code': '+966', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'code': '+962', 'name': 'Jordan', 'flag': '🇯🇴'},
    {'code': '+961', 'name': 'Lebanon', 'flag': '🇱🇧'},
    {'code': '+212', 'name': 'Morocco', 'flag': '🇲🇦'},
    {'code': '+216', 'name': 'Tunisia', 'flag': '🇹🇳'},
    {'code': '+213', 'name': 'Algeria', 'flag': '🇩🇿'},
  ];

  bool _isLoading = false;
  String? _errorMessage;
  gender_model.Gender? _selectedGender;
  late final ValueNotifier<gender_model.Gender?> _genderNotifier;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _genderNotifier = ValueNotifier<gender_model.Gender?>(
      gender_model.Gender.male,
    );
    _selectedGender = gender_model.Gender.male;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    // Navigate to SMS verification with registration data
    final registrationData = {
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': '$_selectedCountryCode${_phoneController.text.trim()}',
      'sex': _selectedGender?.name ?? 'male',
      if (_selectedDate != null) 'dob': _selectedDate!,
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SmsVerificationScreen(
          phoneNumber: _phoneController.text.trim(),
          countryCode: _selectedCountryCode,
          registrationData: registrationData,
          isRegistration: true,
          onSuccess: () {
            // For registration flow, we might want to go back to where user started registration
            // Pop SMS, registration, and potentially the login screen if they exist
            Navigator.of(context).pop(); // Close SMS screen
            Navigator.of(context).pop(); // Close registration screen
            // Check if there's a login screen to close as well
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(); // Close login screen if it exists
            }
          },
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kBrandPrimary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).get('full-name-required');
    }
    if (value.length < 2) {
      return AppLocalizations.of(context).get('full-name-min-length');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).get('email-required');
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return AppLocalizations.of(context).get('email-invalid');
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).get('phone-required');
    }

    // Basic phone validation - can be improved based on requirements
    if (value.length < 10) {
      return AppLocalizations.of(context).get('phone-invalid');
    }

    return null;
  }

  void _showGenderDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  AppLocalizations.of(context).get('gender'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...gender_model.Gender.values.map((gender) {
                return ListTile(
                  title: Text(
                    gender.getLabel(context),
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: _selectedGender == gender
                      ? const Icon(Icons.check, color: Color(0xFF8B5CF6))
                      : null,
                  onTap: () {
                    _genderNotifier.value = gender;
                    _selectedGender = gender;
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context).get('create-account'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  AppLocalizations.of(context).get('registration-title'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  AppLocalizations.of(context).get('registration-subtitle'),
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Full Name field
                LabeledTextFormField(
                  controller: _fullNameController,
                  titleKey: 'full-name',
                  hintTextKey: 'full-name',
                  customValidator: _validateFullName,
                ),

                const SizedBox(height: 16),

                // Email field
                LabeledTextFormField(
                  controller: _emailController,
                  titleKey: 'email',
                  hintTextKey: 'email',
                  keyboardType: TextInputType.emailAddress,
                  customValidator: _validateEmail,
                ),

                const SizedBox(height: 16),

                // Phone number field with country code
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with asterisk
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(
                              context,
                            ).get('phone-number'),
                          ),
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Phone input row
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Container(
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
                            // Country code dropdown
                            Container(
                              padding: const EdgeInsets.only(left: 16),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCountryCode,
                                  items: _countryCodes.map((country) {
                                    return DropdownMenuItem<String>(
                                      value: country['code'],
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            country['code']!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                            textDirection: TextDirection.ltr,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            country['flag']!,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedCountryCode = newValue!;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                  iconSize: 20,
                                  dropdownColor: Colors.grey[900],
                                  style: const TextStyle(color: Colors.white),
                                  isDense: true,
                                  alignment: AlignmentDirectional.centerStart,
                                  selectedItemBuilder: (BuildContext context) {
                                    return _countryCodes.map<Widget>((country) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            country['flag']!,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            country['code']!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                            textDirection: TextDirection.ltr,
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),

                            // Separator
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.grey[600],
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),

                            // Phone number input
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  ).get('phone-number'),
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 16,
                                  ),
                                ),
                                validator: _validatePhone,
                              ),
                            ),

                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Date of Birth field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context).get('date-of-birth')} (${AppLocalizations.of(context).get('optional')})',
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
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
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null
                                  ? AppLocalizations.of(
                                      context,
                                    ).get('date-of-birth')
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDate == null
                                    ? Colors.grey[400]
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Gender selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).get('gender'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<gender_model.Gender?>(
                      valueListenable: _genderNotifier,
                      builder: (context, selectedGender, child) {
                        return GestureDetector(
                          onTap: () {
                            _showGenderDropdown(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(77),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.grey[800]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedGender?.getLabel(context) ??
                                      AppLocalizations.of(
                                        context,
                                      ).get('gender'),
                                  style: TextStyle(
                                    color: selectedGender != null
                                        ? Colors.white
                                        : Colors.grey[400],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Register button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppLocalizations.of(context).get('create-account'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
