import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_localizations.dart';

class LabeledTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String titleKey;
  final String hintTextKey;
  final String? errorTextKey;
  final bool isRequired;
  final int maxLines;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final String? Function(String?)? customValidator;

  const LabeledTextFormField({
    super.key,
    required this.controller,
    required this.titleKey,
    required this.hintTextKey,
    this.errorTextKey,
    this.isRequired = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.customValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with optional asterisk
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: AppLocalizations.of(context).get(titleKey),
              ),
              if (isRequired)
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
        
        // Text Field
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).get(hintTextKey),
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.black.withAlpha(77),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              borderSide: const BorderSide(
                color: Color(0xFF8B5CF6),
                width: 2,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
          validator: customValidator ?? (isRequired 
            ? (value) {
                if (value == null || value.isEmpty) {
                  return errorTextKey != null 
                    ? AppLocalizations.of(context).get(errorTextKey!)
                    : AppLocalizations.of(context).get('$titleKey-required');
                }
                return null;
              }
            : null),
          onChanged: onChanged,
        ),
      ],
    );
  }
}