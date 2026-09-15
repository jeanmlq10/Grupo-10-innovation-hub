import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The "cloud character" illustration for "Comencemos" (Nueva idea).
///
/// The body/outline is the EXACT SVG path exported from Figma's dev-mode
/// panel (273×265 viewBox, black 1px stroke, no fill) — rendered as-is
/// with `flutter_svg`, not redrawn or approximated. Figma's export only
/// included that one outline path (the cloud silhouette, its two legs
/// and the loop/arm); it did not include the eyes or the smile as
/// separate vector layers, so those two small details are added here as
/// a thin overlay in the same stroke style, positioned to match the
/// reference image. If the eyes/mouth are ever exported as their own
/// SVG paths, they can replace this overlay for full pixel fidelity.
class IdeaCloudIllustration extends StatelessWidget {
  const IdeaCloudIllustration({super.key, this.size = 260});

  final double size;

  // Exact export from Figma (Disposición: 272×263.5 rounded to the
  // viewBox's 273×265; Estilo: stroke-width 1px, stroke #000).
  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="273" height="265" viewBox="0 0 273 265" fill="none">
<path d="M152.978 196.415C160.572 195.584 167.405 191.736 175.857 184.835C194.398 183.01 202.528 178.006 210.174 157.043C231.755 145.682 233.02 138.912 232.206 126.724C239.103 119.034 242.535 110.976 242.877 106.933C243.258 102.418 239.541 93.6258 232.206 85.0363C237.322 69.3928 234.508 60.8745 215.682 46.2959C218.156 29.7654 209.397 24.965 185.177 20.1882C175.622 4.34286 166.27 4.60359 148.318 7.97658C133.855 -2.15218 124.905 -1.83091 107.645 7.97658C88.7537 4.78851 81.1086 9.61619 70.7849 25.6624C47.0015 34.007 40.6317 43.8452 37.3145 67.3504C25.2788 76.6464 22.1826 84.2979 30.112 106.933C24.9923 122.451 28.7111 131.748 47.9064 149.463C49.4107 166.451 51.403 175.371 79.2585 178.519C94.909 193.448 105.273 197.333 128.405 191.151C138.446 195.411 146.03 197.175 152.978 196.415ZM47.9064 149.463C18.4186 167.991 3.98535 157.183 0.454712 149.463M242.877 106.933C262.215 108.831 272.455 85.0363 272.455 85.0363M107.645 193.875C107.645 189.02 107.645 245.67 107.645 245.67C107.645 245.67 89.003 264 92.8161 264C96.6292 264 116.118 264 116.118 264M152.978 196.415V242.103C152.978 242.103 148.318 250.946 139.42 257.684C130.523 264.421 161.028 257.684 161.028 257.684M116.118 106.933C131.386 117.859 139.32 116.153 152.978 106.933" stroke="black"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final height = size * (265 / 273);
    return SizedBox(
      width: size,
      height: height,
      child: Stack(
        children: [
          SvgPicture.string(
            _svg,
            width: size,
            height: height,
            fit: BoxFit.contain,
          ),
          CustomPaint(
            size: Size(size, height),
            painter: _FacePainter(),
          ),
        ],
      ),
    );
  }
}

/// Just the eyes + smile, in the viewBox's own black-stroke style —
/// positioned by fraction of the 273×265 box so they scale correctly
/// with [IdeaCloudIllustration.size].
class _FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(w * 0.40, h * 0.38), w * 0.018, eyePaint);
    canvas.drawCircle(Offset(w * 0.55, h * 0.38), w * 0.018, eyePaint);

    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(w * 0.44, h * 0.45)
      ..quadraticBezierTo(w * 0.475, h * 0.475, w * 0.51, h * 0.45);
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) => false;
}
