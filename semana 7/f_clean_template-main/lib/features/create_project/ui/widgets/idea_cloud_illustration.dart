import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Nube de "Nueva idea" basada en la referencia de Figma.
/// Se mantiene como SVG para conservar nitidez y proporciones.
class IdeaCloudIllustration extends StatelessWidget {
  const IdeaCloudIllustration({super.key, this.size = 230});

  final double size;

  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 273 265" fill="none">
<path d="M152.98 196.42C160.57 195.58 167.41 191.74 175.86 184.84C194.4 183.01 202.53 178.01 210.17 157.04C231.76 145.68 233.02 138.91 232.21 126.72C239.1 119.03 242.54 110.98 242.88 106.93C243.26 102.42 239.54 93.63 232.21 85.04C237.32 69.39 234.51 60.87 215.68 46.3C218.16 29.77 209.4 24.97 185.18 20.19C175.62 4.34 166.27 4.6 148.32 7.98C133.86-2.15 124.91-1.83 107.65 7.98C88.75 4.79 81.11 9.62 70.78 25.66C47 34.01 40.63 43.85 37.31 67.35C25.28 76.65 22.18 84.3 30.11 106.93C25 122.45 28.71 131.75 47.91 149.46C49.41 166.45 51.4 175.37 79.26 178.52C94.91 193.45 105.27 197.33 128.4 191.15C138.45 195.41 146.03 197.18 152.98 196.42Z" stroke="#000" stroke-width="1.2"/>
<path d="M47.91 149.46C18.42 167.99 3.99 157.18 0.45 149.46M242.88 106.93C262.22 108.83 272.46 85.04 272.46 85.04M107.65 193.88V245.67L92.82 264H116.12M152.98 196.42V242.1C152.98 242.1 148.32 250.95 139.42 257.68C130.52 264.42 161.03 257.68 161.03 257.68" stroke="#000" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
<circle cx="109.2" cy="102" r="4.5" fill="#000"/><circle cx="150" cy="102" r="4.5" fill="#000"/>
<path d="M119 116C128 124 137 124 146 116" stroke="#000" stroke-width="1.4" stroke-linecap="round"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final height = size * (265 / 273);
    return SizedBox(
      width: size,
      height: height,
      child: SvgPicture.string(_svg, fit: BoxFit.contain),
    );
  }
}
