import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../controllers/user/user_controller.dart';
import '../../constants.dart';
import '../../app_localizations.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;
  final Map<String, dynamic> registrationData;
  final bool isRegistration;

  const SmsVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
    required this.registrationData,
    this.isRegistration = true,
  });

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> with CodeAutoFill {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _initSmsListener();
    _sendOtpCode();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _initSmsListener() async {
    try {
      // Start listening for SMS
      SmsAutoFill().listenForCode;
    } catch (e) {
      debugPrint('SMS Auto-fill initialization failed: $e');
    }
  }

  @override
  void codeUpdated() {
    // This method is called when SMS code is received
    if (code != null && code!.length == 6) {
      _fillOtpFields(code!);
    }
  }

  void _fillOtpFields(String otpCode) {
    setState(() {
      for (int i = 0; i < otpCode.length && i < 6; i++) {
        _otpControllers[i].text = otpCode[i];
      }
      // Clear error message if any
      if (_errorMessage != null) {
        _errorMessage = null;
      }
    });
    
    // Auto-verify if all fields are filled
    if (otpCode.length == 6) {
      _handleSMSVerification();
    }
  }

  Future<void> _sendOtpCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resendCooldown = 60;
    });

    final userController = Provider.of<UserController>(context, listen: false);
    final fullPhoneNumber = '${widget.countryCode}${widget.phoneNumber}';
    final response = await userController.sendOtpCode(fullPhoneNumber);

    setState(() {
      _isLoading = false;
    });

    if (response != null && response['status'] == 'success') {
      _startResendCooldown();
    } else {
      setState(() {
        _errorMessage = response?['message'] ?? AppLocalizations.of(context).get('sms-send-failed');
      });
    }
  }

  void _startResendCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
        _startResendCooldown();
      }
    });
  }

  Future<void> _handleSMSVerification() async {
    // Combine all OTP digits
    final otpCode = _otpControllers.map((controller) => controller.text).join();
    
    if (otpCode.length != 6) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).get('sms-code-invalid');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userController = Provider.of<UserController>(context, listen: false);
    final fullPhoneNumber = '${widget.countryCode}${widget.phoneNumber}';

    try {
      // First verify the OTP code
      final otpResponse = await userController.verifyOtpCode(
        widget.phoneNumber,
        otpCode,
        countryCode: widget.countryCode,
      );

      if (otpResponse == null || otpResponse['status'] != 'success') {
        setState(() {
          _isLoading = false;
          _errorMessage = otpResponse?['message'] ?? AppLocalizations.of(context).get('sms-verification-failed');
        });
        return;
      }

      // OTP verification successful, proceed with registration or login
      if (widget.isRegistration) {
        // For registration, complete the registration process with SMS verification
        final success = await userController.register(
          fullName: widget.registrationData['fullName'],
          email: widget.registrationData['email'],
          phoneNumber: fullPhoneNumber,
          sex: widget.registrationData['sex'],
          dob: widget.registrationData['dob'],
          smsCode: otpCode,
        );

        setState(() {
          _isLoading = false;
        });

        if (success) {
          if (mounted) {
            Navigator.of(context).pop(); // Close SMS screen
            Navigator.of(context).pop(); // Close registration screen
            Navigator.of(context).pop(); // Close login screen
          }
        } else {
          setState(() {
            _errorMessage = AppLocalizations.of(context).get('registration-failed');
          });
        }
      } else {
        // For login
        final success = await userController.loginWithSMS(
          fullPhoneNumber,
          otpCode,
        );

        setState(() {
          _isLoading = false;
        });

        if (success) {
          if (mounted) {
            Navigator.of(context).pop(); // Close SMS screen
            Navigator.of(context).pop(); // Close login screen
          }
        } else {
          setState(() {
            _errorMessage = AppLocalizations.of(context).get('sms-verification-failed');
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context).get('sms-verification-failed');
      });
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Clear error message when user starts typing
      if (_errorMessage != null) {
        setState(() {
          _errorMessage = null;
        });
      }
      
      // Move to next field if current field has a digit
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        // All fields filled, remove focus
        FocusScope.of(context).unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final last4Digits = widget.phoneNumber.length >= 4 
        ? widget.phoneNumber.substring(widget.phoneNumber.length - 4)
        : widget.phoneNumber;
    
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
          AppLocalizations.of(context).get('sms-verification'),
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
                const SizedBox(height: 40),
                
                // Title
                Text(
                  AppLocalizations.of(context).get('verify-phone-number'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  AppLocalizations.of(context).get('sms-sent-to') + ' ***$last4Digits',
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
                      color: Colors.red.withOpacity(0.1),
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
                
                // SMS Code field - 6 separate squares
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).get('verification-code'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                        return SizedBox(
                          width: 60,
                          height: 70,
                          child: TextFormField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            autofillHints: index == 0 ? [AutofillHints.oneTimeCode] : null,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.black.withAlpha(77),
                              contentPadding: const EdgeInsets.all(0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[800]!,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[800]!,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: kBrandPrimary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.length == 1) {
                                _onOtpChanged(value, index);
                              }
                            },
                            onTap: () {
                              // Clear error when user taps on field
                              if (_errorMessage != null) {
                                setState(() {
                                  _errorMessage = null;
                                });
                              }
                            },
                            inputFormatters: [
                              // Only allow single digit
                              LengthLimitingTextInputFormatter(1),
                            ],
                          ),
                        );
                      }),
                    ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Verify button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSMSVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppLocalizations.of(context).get('verify'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Resend code button
                TextButton(
                  onPressed: _resendCooldown > 0 ? null : _sendOtpCode,
                  child: Text(
                    _resendCooldown > 0
                        ? '${AppLocalizations.of(context).get('resend-code')} ($_resendCooldown)'
                        : AppLocalizations.of(context).get('resend-code'),
                    style: TextStyle(
                      color: _resendCooldown > 0 ? Colors.grey : kBrandPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Change phone number
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context).get('change-phone-number'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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