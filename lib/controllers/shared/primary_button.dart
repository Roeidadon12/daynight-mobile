import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../app_localizations.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String textKey;
  final IconData? trailingIcon;
  final double height;
  final bool flexible;
  final bool disabled;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.textKey,
    this.trailingIcon,
    this.height = 56,
    this.flexible = true,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey : kBrandPrimary,
          foregroundColor: Colors.white,
          side: BorderSide(
            color: disabled ? Colors.grey : kBrandPrimary,
            width: 2,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context).get(textKey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon),
            ],
          ],
        ),
      ),
    );

    if (flexible) {
      return Flexible(
        fit: FlexFit.loose,
        child: button,
      );
    }

    return button;
  }
}
