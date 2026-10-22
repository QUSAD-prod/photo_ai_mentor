import 'dart:math' as math;

import 'package:flutter/material.dart';

// Dims everything outside the crop frame and draws corner brackets plus an
// animated scan line inside it.
class ScannerOverlayPainter extends CustomPainter {
  ScannerOverlayPainter({
    required this.frame,
    required this.dimColor,
    required this.accent,
    required this.scanProgress,
    required this.active,
  }) : super(repaint: scanProgress);

  final Rect frame;
  final Color dimColor;
  final Color accent;
  final Animation<double> scanProgress;
  final bool active;

  static const double radius = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect hole = RRect.fromRectAndRadius(frame, const Radius.circular(radius));

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(hole),
      ),
      Paint()..color = dimColor,
    );

    canvas.drawRRect(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.25),
    );

    final Paint bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 5 : 4
      ..strokeCap = StrokeCap.round
      ..color = active ? accent : Colors.white;
    const double len = 30;
    const double r = radius;
    final double l = frame.left, t = frame.top, rt = frame.right, b = frame.bottom;

    canvas.drawPath(
      Path()
        ..moveTo(l, t + r + len)
        ..lineTo(l, t + r)
        ..arcToPoint(Offset(l + r, t), radius: const Radius.circular(r))
        ..lineTo(l + r + len, t)
        ..moveTo(rt - r - len, t)
        ..lineTo(rt - r, t)
        ..arcToPoint(Offset(rt, t + r), radius: const Radius.circular(r))
        ..lineTo(rt, t + r + len)
        ..moveTo(rt, b - r - len)
        ..lineTo(rt, b - r)
        ..arcToPoint(Offset(rt - r, b), radius: const Radius.circular(r))
        ..lineTo(rt - r - len, b)
        ..moveTo(l + r + len, b)
        ..lineTo(l + r, b)
        ..arcToPoint(Offset(l, b - r), radius: const Radius.circular(r))
        ..lineTo(l, b - r - len),
      bracket,
    );

    final double y = frame.top + 12 + (frame.height - 24) * scanProgress.value;
    final Rect glow = Rect.fromLTRB(frame.left + 16, y - 18, frame.right - 16, y + 18);
    canvas.drawRect(
      glow,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: 0.35), accent.withValues(alpha: 0)],
        ).createShader(glow),
    );
    canvas.drawLine(
      Offset(frame.left + 20, y),
      Offset(frame.right - 20, y),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            accent.withValues(alpha: 0),
            accent,
            const Color(0xFFFFB38A),
            accent,
            accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTRB(frame.left, y - 1, frame.right, y + 1)),
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) =>
      oldDelegate.frame != frame || oldDelegate.active != active || oldDelegate.dimColor != dimColor;
}

// Stand-in for the camera feed when no camera is available (simulator, demo):
// a sheet of exercise-book paper with a handwritten problem on a desk.
class DemoCameraScene extends StatelessWidget {
  const DemoCameraScene({super.key, required this.problem, required this.problemCenterY});

  final String problem;

  // Vertical position of the problem's centre as a fraction of the height,
  // so it lines up with the crop frame.
  final double problemCenterY;

  @override
  Widget build(BuildContext context) {
    final bool ru = Localizations.localeOf(context).languageCode == 'ru';
    final List<String> lines = problem.split('\n');

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        final double centerY = h * problemCenterY;
        const ink = Color(0xFF1F3A8A);
        TextStyle hand(double size, {Color color = ink, FontWeight weight = FontWeight.w500}) => TextStyle(
              fontFamily: 'Caveat',
              fontSize: size,
              color: color,
              fontWeight: weight,
              height: 1.0,
            );

        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B4A33), Color(0xFF3A271B)],
                ),
              ),
            ),
            Transform.rotate(
              angle: -0.035,
              child: Transform.scale(
                scale: 1.04,
                child: Container(
                  margin: EdgeInsets.fromLTRB(w * 0.03, h * 0.02, w * 0.02, h * 0.01),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3EA),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(8, 12),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _GridPaperPainter(),
                  ),
                ),
              ),
            ),
            Positioned(
              left: w * 0.12,
              right: w * 0.06,
              top: centerY - 222,
              child: Transform.rotate(
                angle: -0.035,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ru ? 'Домашняя работа' : 'Homework', style: hand(30, weight: FontWeight.w600)),
                    const SizedBox(height: 14),
                    Text(
                      ru ? '№ 3.  3x + 5 = 20   →   x = 5' : '#3.  3x + 5 = 20   →   x = 5',
                      style: hand(26, color: ink.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: 110),
                    Text(ru ? '№ 4.  ${lines.first}' : '#4.  ${lines.first}', style: hand(30)),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Text(lines.skip(1).join('\n'), style: hand(44, weight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 72),
                    Text(
                      ru ? '№ 5.  Упростите выражение:' : '#5.  Simplify the expression:',
                      style: hand(28, color: ink.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Text('(a + b)² − 2ab', style: hand(32, color: ink.withValues(alpha: 0.8))),
                    ),
                  ],
                ),
              ),
            ),
            // Soft vignette, as from a phone camera.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.1,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GridPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double step = 22;
    final Paint grid = Paint()
      ..color = const Color(0xFF8FB3D9).withValues(alpha: 0.45)
      ..strokeWidth = 0.8;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final double marginX = size.width - step * 2.5;
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      Paint()
        ..color = const Color(0xFFE05A5A).withValues(alpha: 0.6)
        ..strokeWidth = 1.4,
    );

    // A little paper grain so it doesn't look flat.
    final math.Random rnd = math.Random(7);
    final Paint grain = Paint()..color = Colors.black.withValues(alpha: 0.025);
    for (int i = 0; i < 900; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        rnd.nextDouble() * 1.4,
        grain,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPaperPainter oldDelegate) => false;
}
