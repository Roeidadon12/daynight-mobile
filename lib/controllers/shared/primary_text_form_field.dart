import 'package:flutter/material.dart';
import '../../constants.dart';

class PrimaryTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool isRequired;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final bool hasError;

  const PrimaryTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.isRequired = true,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32);
    final outlineBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(
        color: Colors.grey[800]!,
        width: 1,
      ),
    );
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        labelStyle: TextStyle(
          color: hasError ? Colors.red[400] : Colors.grey[400],
          fontSize: 16,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withAlpha(77),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: outlineBorder,
        enabledBorder: hasError 
          ? outlineBorder.copyWith(
              borderSide: BorderSide(
                color: Colors.red[400]!,
                width: 1,
              ),
            )
          : outlineBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: kBrandPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: Colors.red[400]!,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: Colors.red[400]!,
            width: 2,
          ),
        ),
      ),
      validator: validator ?? (isRequired 
        ? (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${labelText.toLowerCase()}';
            }
            return null;
          }
        : null),
    );
  }
}