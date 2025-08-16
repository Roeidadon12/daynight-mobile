import 'package:flutter/material.dart';
import '../../app_localizations.dart';

class SearchCriteriaButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;

  const SearchCriteriaButton({
    super.key,
    required this.onTap,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context).get('search-events'),
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}