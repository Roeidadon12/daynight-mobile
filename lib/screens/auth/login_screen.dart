import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user/user_controller.dart';
import '../../constants.dart';
import '../../app_localizations.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isAwaitingSMS = false; // SMS verification mode
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
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
    final success = await userController.sendSMSCode(_phoneController.text.trim());

    setState(() {
      _isLoading = false;
      if (success) {
        _isAwaitingSMS = true;
      } else {
        _errorMessage = AppLocalizations.of(context).get('sms-send-failed');
      }
    });
  }

  Future<void> _handleSMSLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userController = Provider.of<UserController>(context, listen: false);
    final success = await userController.loginWithSMS(
      _phoneController.text.trim(),
      _smsCodeController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.of(context).pop(); // Return to previous screen
      }
    } else {
      setState(() {
        _errorMessage = AppLocalizations.of(context).get('sms-verification-failed');
      });
    }
  }

  Future<void> _handleGuestLogin() async {
    final userController = Provider.of<UserController>(context, listen: false);
    await userController.continueAsGuest();
    
    if (mounted) {
      Navigator.of(context).pop(); // Return to previous screen
    }
  }

  void _navigateToRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegistrationScreen(),
      ),
    );
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

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).get('phone-required');
    }
    
    // Basic phone number validation
    if (value.length < 9) {
      return AppLocalizations.of(context).get('phone-min-length');
    }
    
    return null;
  }

  String? _validateSMSCode(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).get('sms-code-required');
    }
    
    if (value.length < 4) {
      return AppLocalizations.of(context).get('sms-code-min-length');
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
                
                // SMS mode back button
                if (_isAwaitingSMS) ...[
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isAwaitingSMS = false;
                            _smsCodeController.clear();
                            _errorMessage = null;
                          });
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white70),
                        label: Text(
                          AppLocalizations.of(context).get('back-to-phone'),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    '${AppLocalizations.of(context).get('sms-sent-to')} ${_phoneController.text}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Social login buttons (only show when not awaiting SMS)
                if (!_isAwaitingSMS) ...[
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
                ],
                
                // Phone number field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).get('phone-number'),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validatePhoneNumber,
                ),
                
                const SizedBox(height: 20),
                
                // SMS code field (only show in SMS awaiting mode)
                if (_isAwaitingSMS) ...[
                  TextFormField(
                    controller: _smsCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).get('sms-verification-code'),
                      prefixIcon: const Icon(Icons.sms_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: _validateSMSCode,
                  ),
                  
                  const SizedBox(height: 24),
                ],
                
                // Password field (hidden during SMS flow)
                if (!_isAwaitingSMS)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).get('password'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: _validatePassword,
                  ),
                
                if (!_isAwaitingSMS) const SizedBox(height: 24),
                
                // Main action button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_isAwaitingSMS ? _handleSMSLogin : _handleSendSMS),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isAwaitingSMS 
                              ? AppLocalizations.of(context).get('verify-sms-code')
                              : AppLocalizations.of(context).get('send-sms-code'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Guest login button
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGuestLogin,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).get('continue-as-guest'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white30)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppLocalizations.of(context).get('or'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white30)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Registration prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).get('no-account'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: _navigateToRegistration,
                      child: Text(
                        AppLocalizations.of(context).get('create-account'),
                        style: TextStyle(
                          color: kBrandPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}