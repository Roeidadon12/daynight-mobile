import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user/user_controller.dart';
import '../../controllers/shared/labeled_text_form_field.dart';
import '../../constants.dart';
import '../../app_localizations.dart';
import 'sms_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCountryCode = '+972'; // Default to Israel

  // Country codes list with flags
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

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin() async {
    final userController = Provider.of<UserController>(context, listen: false);
    final success = await userController.loginWithGoogle();
    
    if (success) {
      if (mounted) {
        Navigator.of(context).pop(); // Return to previous screen
      }
    } else {
      setState(() {
        _errorMessage = AppLocalizations.of(context).get('login-failed');
      });
    }
  }

  Future<void> _handleAppleLogin() async {
    final userController = Provider.of<UserController>(context, listen: false);
    final success = await userController.loginWithApple();
    
    if (success) {
      if (mounted) {
        Navigator.of(context).pop(); // Return to previous screen
      }
    } else {
      setState(() {
        _errorMessage = AppLocalizations.of(context).get('login-failed');
      });
    }
  }

  Future<void> _handleSendSMS() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userController = Provider.of<UserController>(context, listen: false);
    
    final response = await userController.sendOtpCode(
      _phoneController.text.trim(),
      countryCode: _selectedCountryCode,
    );

    setState(() {
      _isLoading = false;
    });

    if (response != null && response['status'] == 'success') {
      // Navigate to SMS verification screen for login flow
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SmsVerificationScreen(
              phoneNumber: _phoneController.text.trim(),
              countryCode: _selectedCountryCode,
              registrationData: {}, // Empty for login flow
              isRegistration: false, // This is a login flow
            ),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = response?['message'] ?? AppLocalizations.of(context).get('sms-send-failed');
      });
    }
  }

  void _openTermsAndConditions() {
    // TODO: Replace with actual EULA URL
    const eulaUrl = 'https://example.com/terms-and-conditions';
    _showUrlDialog('Terms and Conditions', eulaUrl);
  }

  void _openPrivacyPolicy() {
    // TODO: Replace with actual Privacy Policy URL
    const privacyPolicyUrl = 'https://example.com/privacy-policy';
    _showUrlDialog('Privacy Policy', privacyPolicyUrl);
  }

  void _showUrlDialog(String title, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please visit the following URL:'),
              const SizedBox(height: 8),
              SelectableText(
                url,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    // Email is optional, but if provided it must be valid
    if (value == null || value.isEmpty) {
      return null; // Allow empty email
    }
    
    // Comprehensive email validation using regex
    // This pattern validates most common email formats including:
    // - Letters, numbers, dots, hyphens, underscores in local part
    // - Multiple domain levels
    // - International domain extensions
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return AppLocalizations.of(context).get('email-invalid');
    }
    
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).get('phone-required');
    }
    
    // Remove any spaces, dashes, or other formatting
    String cleanedNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Basic phone number validation - should be digits only and reasonable length
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedNumber)) {
      return AppLocalizations.of(context).get('phone-invalid');
    }
    
    // Check minimum length (without country code)
    if (cleanedNumber.length < 7) {
      return AppLocalizations.of(context).get('phone-min-length');
    }
    
    return null;
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
          AppLocalizations.of(context).get('connect-subscribe'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Connect/Subscribe title - large and aligned to start
                Text(
                  AppLocalizations.of(context).get('connect-subscribe'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.start,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle - smaller text aligned to start
                Text(
                  AppLocalizations.of(context).get('phone-number-required-for-identification'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.start,
                ),
                
                const SizedBox(height: 50),
                
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
                
                // Google login button
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a1a1a), // Dark background
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25), // More rounded
                        side: BorderSide(color: Colors.grey.shade600, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context).get('connect-with-google'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  
                const SizedBox(height: 20),
                
                // Apple login button (iOS only)
                if (Platform.isIOS)
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAppleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25), // More rounded
                          side: BorderSide(color: Colors.grey.shade600, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.apple,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context).get('connect-with-apple'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                if (Platform.isIOS) const SizedBox(height: 20),
                
                // OR Divider
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white30, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          AppLocalizations.of(context).get('or'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white30, thickness: 1)),
                    ],
                  ),
                ),
                
                // Email field (optional)
                LabeledTextFormField(
                  controller: _emailController,
                  titleKey: 'email-optional',
                  hintTextKey: 'email',
                  keyboardType: TextInputType.emailAddress,
                  customValidator: _validateEmail,
                ),
                
                const SizedBox(height: 20),
                
                const SizedBox(height: 8),

                // Phone number field with country code (dark themed)
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
                            text: AppLocalizations.of(context).get('phone-number'),
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
                                        mainAxisAlignment: MainAxisAlignment.start,
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
                                            style: const TextStyle(fontSize: 18),
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
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
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
                                            style: const TextStyle(fontSize: 18),
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
                                  hintText: AppLocalizations.of(context).get('phone-number'),
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                                ),
                                validator: _validatePhoneNumber,
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
                
                // Terms and Privacy Policy text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context).get('by-pressing-continue-approve'),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => _openTermsAndConditions(),
                            child: Text(
                              AppLocalizations.of(context).get('terms-and-conditions-link'),
                              style: TextStyle(
                                color: kBrandPrimary,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: kBrandPrimary,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' ${AppLocalizations.of(context).get('and')} ',
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => _openPrivacyPolicy(),
                            child: Text(
                              AppLocalizations.of(context).get('privacy-policy-link'),
                              style: TextStyle(
                                color: kBrandPrimary,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: kBrandPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Send SMS button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendSMS,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppLocalizations.of(context).get('send-sms-code'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}