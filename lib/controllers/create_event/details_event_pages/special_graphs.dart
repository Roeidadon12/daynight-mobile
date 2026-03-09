import 'dart:math' as math;

import 'package:day_night/app_localizations.dart';
import 'package:flutter/material.dart';

class SpecialGraphsSection extends StatelessWidget {
  final int womenCount;
  final int menCount;

  const SpecialGraphsSection({
    super.key,
    required this.womenCount,
    required this.menCount,
  });

  int get _totalParticipants => womenCount + menCount;

  double get _womenRatio {
    if (_totalParticipants <= 0) return 0.5;
    return womenCount / _totalParticipants;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2638),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        localizations.get('special-graphs-sales-by-gender'),
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          localizations.get('special-graphs-women'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$womenCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          localizations.get('special-graphs-men'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$menCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 170,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size.square(150),
                            painter: _GenderDonutPainter(
                              womenRatio: _womenRatio,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                localizations.get('special-graphs-total'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${localizations.get('special-graphs-participants')} $_totalParticipants',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderDonutPainter extends CustomPainter {
  final double womenRatio;

  _GenderDonutPainter({required this.womenRatio});

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -math.pi / 2;
    const strokeWidth = 20.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.white.withValues(alpha: 0.10);
    canvas.drawArc(rect, 0, math.pi * 2, false, bgPaint);

    final womenSweep = (math.pi * 2) * womenRatio;
    final menSweep = (math.pi * 2) - womenSweep;

    final womenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFE548BF);

    final menPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFF3A97FF);

    canvas.drawArc(rect, startAngle, womenSweep, false, womenPaint);
    canvas.drawArc(rect, startAngle + womenSweep, menSweep, false, menPaint);
  }

  @override
  bool shouldRepaint(covariant _GenderDonutPainter oldDelegate) {
    return oldDelegate.womenRatio != womenRatio;
  }
}
