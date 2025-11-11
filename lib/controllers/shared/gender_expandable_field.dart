import 'package:flutter/material.dart';
import '../../models/gender.dart';
import 'expandable_select_field.dart';

class GenderExpandableField extends StatelessWidget {
  final String labelKey;
  final Gender? selected;
  final List<Gender> options;
  final ValueChanged<Gender?> onChanged;
  final bool isRequired;
  final bool hasError;

  const GenderExpandableField({
    super.key,
    required this.labelKey,
    required this.selected,
    required this.options,
    required this.onChanged,
    this.isRequired = true,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableSelect<Gender>(
      labelKey: labelKey,
      selected: selected,
      options: options,
      onChanged: onChanged,
      getLabel: (g, ctx) => g.getLabel(ctx),
      isRequired: isRequired,
      hasError: hasError,
    );
  }
}
