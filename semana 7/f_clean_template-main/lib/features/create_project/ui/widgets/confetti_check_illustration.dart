import 'package:flutter/material.dart';

import '../../../home/ui/home_colors.dart';

/// The purple checkmark circle with scattered confetti dots on
/// "¡Proyecto publicado!". Hand-drawn with `CustomPainter` (same
/// reasoning as `IdeaCloudIllustration`'s overlay: this is an
/// approximation of the reference's confetti burst, not an exact vector
/// import, since no source asset exists for it either).
class ConfettiCheckIllustration extends StatelessWidget {
  const ConfettiCheckIllustration({super.key, this.size = 170});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ConfettiPainter()),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  static const List<Color> _confettiColors = [
    Color(0xFF4B309E),
    Color(0xFFE0A23C),
    Color(0xFF3E8E5C),
    Color(0xFFD9695B),
    Color(0xFF6A4FC0),
  ];

  // (fractionX, fractionY, sizeFraction, colorIndex, shape)
  // shape: 0 = dot, 1 = short dash
  static const List<List<double>> _confetti = [
    [0.08, 0.20, 0.035, 0, 0],
    [0.18, 0.05, 0.03, 1, 1],
    [0.34, 0.02, 0.03, 2, 0],
    [0.62, 0.03, 0.035, 3, 1],
    [0.82, 0.10, 0.03, 4, 0],
    [0.92, 0.30, 0.035, 1, 1],
    [0.90, 0.55, 0.03, 2, 0],
    [0.06, 0.55, 0.03, 3, 1],
    [0.02, 0.38, 0.025, 4, 0],
    [0.50, 0.0, 0.025, 0, 0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.32;

    for (final dot in _confetti) {
      final color = _confettiColors[dot[3].toInt()];
      final paint = Paint()..color = color;
      final position = Offset(w * dot[0], h * dot[1]);
      if (dot[4] == 0) {
        canvas.drawCircle(position, w * dot[2], paint);
      } else {
        final dashPaint = Paint()
          ..color = color
          ..strokeWidth = w * 0.02
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          position,
          position.translate(w * dot[2], w * dot[2]),
          dashPaint,
        );
      }
    }

    canvas.drawCircle(center, radius, Paint()..color = HomeColors.primaryPurple);

    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final checkPath = Path()
      ..moveTo(center.dx - radius * 0.45, center.dy)
      ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.35)
      ..lineTo(center.dx + radius * 0.5, center.dy - radius * 0.35);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}
