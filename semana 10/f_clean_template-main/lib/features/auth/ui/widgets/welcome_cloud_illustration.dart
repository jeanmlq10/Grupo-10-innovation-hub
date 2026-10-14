import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ilustración de bienvenida exactamente en la proporción del flujo:
/// nube/personaje grande, brazo izquierdo curvado, brazo derecho unido al
/// candado, sonrisa negra y las dos piernas visibles.
class WelcomeCloudIllustration extends StatelessWidget {
  const WelcomeCloudIllustration({super.key, this.size = 350});

  /// Ancho total de la ilustración, incluyendo el candado.
  final double size;

  static const double _viewBoxWidth = 322;
  static const double _viewBoxHeight = 266;

  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 322 266" fill="none">
  <!-- Nube/personaje -->
  <path d="M152.98 196.42
    C160.57 195.58 167.41 191.74 175.86 184.84
    C194.4 183.01 202.53 178.01 210.17 157.04
    C231.76 145.68 233.02 138.91 232.21 126.72
    C239.1 119.03 242.54 110.98 242.88 106.93
    C243.26 102.42 239.54 93.63 232.21 85.04
    C237.32 69.39 234.51 60.87 215.68 46.3
    C218.16 29.77 209.4 24.97 185.18 20.19
    C175.62 4.34 166.27 4.6 148.32 7.98
    C133.86 -2.15 124.91 -1.83 107.65 7.98
    C88.75 4.79 81.11 9.62 70.78 25.66
    C47 34.01 40.63 43.85 37.31 67.35
    C25.28 76.65 22.18 84.3 30.11 106.93
    C25 122.45 28.71 131.75 47.91 149.46
    C49.41 166.45 51.4 175.37 79.26 178.52
    C94.91 193.45 105.27 197.33 128.4 191.15
    C138.45 195.41 146.03 197.18 152.98 196.42Z"
    fill="#FFFFFF"
    stroke="#16153F"
    stroke-width="1.6"
    stroke-linejoin="round"/>

  <!-- Brazo izquierdo -->
  <path d="M47.91 149.46
    C28.5 161.8 10.5 164.4 0.95 149.46"
    stroke="#16153F"
    stroke-width="1.6"
    stroke-linecap="round"
    stroke-linejoin="round"/>

  <!-- Brazo derecho hacia el candado -->
  <path d="M240.5 100
    C250 99.5 259 94.5 270 87"
    stroke="#16153F"
    stroke-width="1.6"
    stroke-linecap="round"
    stroke-linejoin="round"/>

  <!-- Piernas -->
  <path d="M107.65 193.88V245.67L92.82 264.5H116.12"
    stroke="#16153F"
    stroke-width="1.6"
    stroke-linecap="round"
    stroke-linejoin="round"/>
  <path d="M152.98 196.42V242.1
    C152.98 242.1 148.32 250.95 139.42 257.68
    C130.52 264.42 161.03 257.68 161.03 257.68"
    stroke="#16153F"
    stroke-width="1.6"
    stroke-linecap="round"
    stroke-linejoin="round"/>

  <!-- Ojos -->
  <ellipse cx="111" cy="96" rx="4.6" ry="6" fill="#16153F"/>
  <ellipse cx="148" cy="96" rx="4.6" ry="6" fill="#16153F"/>

  <!-- Sonrisa -->
  <path d="M118 116C125 122 134 122 141 116"
    stroke="#000000"
    stroke-width="2.4"
    stroke-linecap="round"/>

  <!-- Candado -->
  <path d="M281 62V51
    C281 43.8 286.8 38 294 38
    C301.2 38 307 43.8 307 51V62"
    stroke="#16153F"
    stroke-width="2.2"
    stroke-linecap="round"/>
  <rect x="270" y="62" width="48" height="50" rx="7"
    fill="#FFFFFF"
    stroke="#16153F"
    stroke-width="2.2"/>
  <circle cx="294" cy="82" r="4.8" fill="#16153F"/>
  <path d="M294 85V97"
    stroke="#16153F"
    stroke-width="3"
    stroke-linecap="round"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final height = size * (_viewBoxHeight / _viewBoxWidth);

    return SizedBox(
      width: size,
      height: height,
      child: SvgPicture.string(
        _svg,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}
