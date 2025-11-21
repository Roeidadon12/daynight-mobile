import 'package:flutter/material.dart';
import 'package:day_night/constants.dart';
import 'package:day_night/controllers/shared/custom_app_bar.dart';

class LoadingOverlayController extends StatelessWidget {
  final String title;
  final String label;
  final bool disableBackButton;
  final VoidCallback? onBackPressed;
  final Color? spinnerColor;
  final Color? backgroundColor;
  final double spinnerSize;
  final double spinnerStrokeWidth;

  const LoadingOverlayController({
    super.key,
    required this.title,
    required this.label,
    this.disableBackButton = true,
    this.onBackPressed,
    this.spinnerColor,
    this.backgroundColor,
    this.spinnerSize = 80.0,
    this.spinnerStrokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? kMainBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              titleKey: title,
              onBackPressed: disableBackButton ? null : onBackPressed,
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Custom loading spinner
                    SizedBox(
                      width: spinnerSize,
                      height: spinnerSize,
                      child: CircularProgressIndicator(
                        strokeWidth: spinnerStrokeWidth,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          spinnerColor ?? kBrandPrimary,
                        ),
                        backgroundColor: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Loading text
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}