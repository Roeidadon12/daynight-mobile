import 'package:flutter/material.dart';
import '../app_localizations.dart';

class EditingTab extends StatelessWidget {
  const EditingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Center(
        child: Text(
          AppLocalizations.of(context).get('editing - page'),
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
