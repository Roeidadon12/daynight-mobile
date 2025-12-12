import 'package:flutter/material.dart';

class CreateStepTitle extends StatelessWidget {
  final String title;
  final String description;

  const CreateStepTitle({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = Colors.grey[400]!;
    const Color descriptionColor = Colors.white;
    const double titleFontSize = 14;
    const double descriptionFontSize = 20;
    const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return Container(
      width: double.infinity,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: titleFontSize,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: descriptionColor,
              fontSize: descriptionFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
