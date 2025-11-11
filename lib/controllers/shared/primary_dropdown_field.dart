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
      // Opened-list design: rounded items, clearer selection, better spacing
      items: items.map((item) {
        final bool isSelected = value == item;
        return DropdownMenuItem<T>(
          value: item,
          child: Container(
            // Do not force width; let dropdown constraints size it
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? kBrandPrimary.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: kBrandPrimary.withValues(alpha: 0.30),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              // Avoid flex-based expansion inside dropdown items (unbounded width)
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    getLabel(item, context),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? kBrandPrimary : Colors.white,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: kBrandPrimary,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      // Use app constants; avoid deprecated withOpacity
      dropdownColor: kMainBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 12,
      menuMaxHeight: 280,
      decoration: InputDecoration(
        labelText: isRequired 
          ? '${AppLocalizations.of(context).get(labelKey)} *'
          : AppLocalizations.of(context).get(labelKey),
        labelStyle: TextStyle(
          color: hasError ? kBrandNegativePrimary : Colors.grey[400],
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.black.withAlpha(77),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: outlineBorder,
        enabledBorder: hasError 
          ? outlineBorder.copyWith(
              borderSide: BorderSide(
                color: kBrandNegativePrimary,
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
            color: kBrandNegativePrimary,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: kBrandNegativePrimary,
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