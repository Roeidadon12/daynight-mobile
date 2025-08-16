import 'package:flutter/material.dart';
import '../../constants.dart';

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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? kBrandPrimary : Colors.transparent,
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white,
                    width: 0.8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      height / 2, // Make the button rounded
                    ), // Optional: rounded corners
                  ),
                ),
                onPressed: delegates[label],
                child: Text(label),
              ),
            );
          }),
        ),
      ),
    );
  }
}
