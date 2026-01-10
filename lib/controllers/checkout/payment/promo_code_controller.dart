import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/app_localizations.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class PromoCodeField extends StatefulWidget {
  final Function(String promoCode)? onPromoCodeApplied;
  final Function()? onTextChanged; // New callback to clear messages when typing
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const PromoCodeField({
    super.key,
    this.onPromoCodeApplied,
    this.onTextChanged,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFieldFocused = _focusNode.hasFocus;
      });
    });
    
    _controller.addListener(() {
      setState(() {
        // Rebuild to update button state when text changes
      });
      // Clear error/success messages when user starts typing
      if (widget.onTextChanged != null) {
        widget.onTextChanged!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleApplyPromoCode() {
    final promoCode = _controller.text.trim();
    if (promoCode.isNotEmpty && widget.onPromoCodeApplied != null) {
      widget.onPromoCodeApplied!(promoCode);
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorMessage != null;
    final hasSuccess = widget.successMessage != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28), // Full circle edges
            color: Colors.black.withValues(alpha: 0.3), // Darker, more transparent background
            border: Border.all(
              color: hasError 
                  ? kBrandNegativePrimary
                  : hasSuccess
                      ? Colors.green.shade400
                      : _isFieldFocused
                          ? kBrandPrimary
                          : Colors.grey.shade600,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Text input field (75% of width)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !widget.isLoading,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).get('promo-code'),
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _handleApplyPromoCode(),
                  ),
                ),
              ),
              // Vertical separator line
              Container(
                height: double.infinity,
                width: 1,
                color: Colors.white,
              ),
              // OK Button (25% of width)
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: widget.isLoading || _controller.text.trim().isEmpty 
                      ? null 
                      : _handleApplyPromoCode,
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context).get('ok'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Error or Success message
        if (hasError || hasSuccess) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              hasError ? widget.errorMessage! : widget.successMessage!,
              style: TextStyle(
                color: hasError ? kBrandNegativePrimary : Colors.green,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
