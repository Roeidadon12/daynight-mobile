import 'package:flutter/material.dart';
import 'search_price_criteria.dart';

Future<Map<String, Object?>?> showCustomPriceRange(BuildContext context) async {
  final result = await showCustomPriceRangePicker(context);
  
  if (result == null) {
    return null;
  }

  return {
    'min': result['min'] as double?,
    'max': result['max'] as double?,
    'currency': result['currency'],
  };
}
