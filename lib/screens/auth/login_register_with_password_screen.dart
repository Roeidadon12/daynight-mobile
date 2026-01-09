import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user/user_controller.dart';
import '../../constants.dart';
import '../../app_localizations.dart';
import '../../utils/country_codes.dart';

class LoginRegisterWithPasswordScreen extends StatefulWidget {
  const LoginRegisterWithPasswordScreen({super.key});

  @override
  State<LoginRegisterWithPasswordScreen> createState() => _LoginRegisterWithPasswordScreenState();
}

class _LoginRegisterWithPasswordScreenState extends State<LoginRegisterWithPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoginMode = true; // true for login, false for register
  bool _obscurePassword = true;
  String _selectedCountryCode = CountryCodes.defaultCountryCode;

  // Get enabled country codes from centralized utility
  List<Map<String, String>> get _countryCodes => CountryCodes.enabledAsMaps;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handlePhonePasswordAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userController = Provider.of<UserController>(context, listen: false);
    bool success = false;

    try {
      if (_isLoginMode) {
        // Login with phone and password - TODO: Need to implement this in user controller
        // For now, using email login as placeholder
        success = await userController.login(
          _phoneController.text.trim(),
          _passwordController.text,
        );
      } else {
        // Register with phone and password
        // TODO: Implement registration with phone/password
        success = false;
        setState(() {
          _errorMessage = 'Registration functionality not implemented yet';
        });
      }

      if (success && mounted) {
        Navigator.of(context).pop(); // Return to previous screen
        Navigator.of(context).pop(); // Return to main app
      } else if (!success && _errorMessage == null) {
        setState(() {
          _errorMessage = AppLocalizations.of(context).get('login-failed');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).get('login-failed');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).get('password-required');
    }
    
    if (value.length < 6) {
      return AppLocalizations.of(context).get('password-min-length');
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
          AppLocalizations.of(context).get('login-register'),
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
                
                // Title
                Text(
                  AppLocalizations.of(context).get('login-register'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  _isLoginMode 
                    ? AppLocalizations.of(context).get('login-subtitle')
                    : 'Create a new account to get started',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
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
                
                const SizedBox(height: 20),
                
                // Password field
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
                            text: AppLocalizations.of(context).get('password'),
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).get('password'),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.black.withAlpha(77),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(
                            color: Colors.grey[800]!,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(
                            color: Colors.grey[800]!,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(
                            color: kBrandPrimary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Login/Register button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePhonePasswordAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isLoginMode 
                              ? AppLocalizations.of(context).get('login')
                              : 'Register',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Toggle between login and register
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                        _errorMessage = null;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: _isLoginMode 
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          ),
                          TextSpan(
                            text: _isLoginMode ? 'Register' : 'Login',
                            style: TextStyle(
                              color: kBrandPrimary,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                              decorationColor: kBrandPrimary,
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
        ),
      ),
    );
  }
}