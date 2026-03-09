import 'package:day_night/app_localizations.dart';
import 'package:flutter/material.dart';

class TotalEarningsSection extends StatelessWidget {
  final double totalEarnings;

  const TotalEarningsSection({
    super.key,
    required this.totalEarnings,
  });

  String _formatCurrency(double value) {
    final rounded = value.round();
    final digits = rounded.toString();
    final withCommas = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '₪$withCommas';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SizedBox(
      height: 100,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2638),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    localizations.get('total-earnings'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(totalEarnings),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.show_chart_rounded,
                size: 44,
                color: const Color(0xFF11C782),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
