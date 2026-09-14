import 'package:flutter/material.dart';

/// Draws a dashed rounded-rectangle border around [child].
///
/// Flutter has no built-in dashed/dotted border, and the template does not
/// bring a package for it, so this small painter reproduces the strokes
/// seen in the Figma prototype without adding a new dependency.
///
/// Figma uses two different strokes:
/// - a dashed one (short segments) around "Crea otra idea";
/// - a dotted one (round dots) around each category chip.
///
/// [dotted] switches between the two: `false` draws dashes with flat caps
/// (the default), `true` draws round-capped dots.
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1.5,
    this.gap = 4,
    this.radius = 16,
    this.dotted = false,
  });

  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;
  final bool dotted;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: color,
        strokeWidth: strokeWidth,
        gap: gap,
        radius: radius,
        dotted: dotted,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
    required this.dotted,
  });

  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;
  final bool dotted;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = dotted ? StrokeCap.round : StrokeCap.butt;

    // A dotted stroke is just a dashed one with a near-zero dash length and
    // round caps, so each "dash" renders as a small circle.
    final dashLength = dotted ? 0.01 : gap;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += gap * (dotted ? 1 : 2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gap != gap ||
      oldDelegate.radius != radius ||
      oldDelegate.dotted != dotted;
}
