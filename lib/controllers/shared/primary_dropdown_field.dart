import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../app_localizations.dart';

class PrimaryDropdownField<T> extends StatelessWidget {
  final String labelKey;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String Function(T, BuildContext) getLabel;
  final bool isRequired;
  final String? Function(T?)? validator;
  final bool hasError;

  const PrimaryDropdownField({
    super.key,
    required this.labelKey,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.getLabel,
    this.isRequired = true,
    this.validator,
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

    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            getLabel(item, context),
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      dropdownColor: Colors.black.withAlpha(240),
      decoration: InputDecoration(
        labelText: isRequired 
          ? '${AppLocalizations.of(context).get(labelKey)} *'
          : AppLocalizations.of(context).get(labelKey),
        labelStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.black.withAlpha(77),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: outlineBorder,
        enabledBorder: outlineBorder,
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
            if (value == null) {
              final fieldName = AppLocalizations.of(context).get(labelKey).toLowerCase();
              return AppLocalizations.of(context).get('please-select-field').replaceAll('{field}', fieldName);
            }
            return null;
          }
        : null),
    );
  }
}

// Gender enum moved to models/gender.dart