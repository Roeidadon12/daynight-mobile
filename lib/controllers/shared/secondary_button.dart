import 'package:flutter/material.dart';
import '../../constants.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isSelected;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? selectedColor;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.height = 56,
    this.padding = const EdgeInsets.only(left: 4.0, right: 4.0, top: 8.0),
    this.selectedColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedColor = selectedColor ?? kBrandPrimary;
    final effectiveBorderColor = borderColor ?? Colors.white;

    return Padding(
      padding: padding,
      child: SizedBox(
        height: height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? effectiveSelectedColor : Colors.transparent,
            foregroundColor: Colors.white,
            side: BorderSide(
              color: effectiveBorderColor,
              width: 0.8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                height / 2, // Make the button rounded
              ),
            ),
          ),
          onPressed: onPressed,
          child: Text(text),
        ),
      ),
    );
  }
}
