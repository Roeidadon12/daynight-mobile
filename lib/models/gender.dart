import 'package:flutter/widgets.dart';
import '../app_localizations.dart';

enum Gender {
  male,
  female,
  other;
  
  String getLabel(BuildContext context) {
    switch (this) {
      case Gender.male:
        return AppLocalizations.of(context).get('gender-male');
      case Gender.female:
        return AppLocalizations.of(context).get('gender-female');
      case Gender.other:
        return AppLocalizations.of(context).get('gender-other');
    }
  }
  
  @override
  String toString() {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}