import 'package:flutter/material.dart';
import 'secondary_button.dart';

/// A controller widget that displays a horizontal array of buttons.
/// [labels] is the list of button labels.
/// [delegates] is a map that associates each label with a callback function.
class HorizontalButtonsController extends StatelessWidget {
  final List<String> labels;
  final Map<String, VoidCallback> delegates;
  final int? selectedIndex;
  final double height;

  const HorizontalButtonsController({
    super.key,
    required this.labels,
    required this.delegates,
    this.selectedIndex = -1,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(labels.length, (index) {
            final label = labels[index];
            final isSelected = selectedIndex == index;
            return SecondaryButton(
              text: label,
              isSelected: isSelected,
              onPressed: delegates[label],
              height: height,
            );
          }),
        ),
      ),
    );
  }
}
