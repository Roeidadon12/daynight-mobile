import 'package:flutter/material.dart';
import '../../models/category.dart';
import 'expandable_select_field.dart';

class CategoryExpandableField extends StatelessWidget {
  final String labelKey;
  final Category? selected;
  final List<Category> options;
  final ValueChanged<Category?> onChanged;
  final bool isRequired;
  final bool hasError;

  const CategoryExpandableField({
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
    return ExpandableSelect<Category>(
      labelKey: labelKey,
      selected: selected,
      options: options,
      onChanged: onChanged,
      getLabel: (category, ctx) => category.name,
      isRequired: isRequired,
      hasError: hasError,
    );
  }
}