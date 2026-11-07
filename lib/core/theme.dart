import 'package:flutter/material.dart';

/// Colour from a 0xRRGGBB int and an opacity (0..1). Avoids deprecated Color APIs.
Color rgba(int rgb, [double opacity = 1.0]) {
  int a = (opacity * 255).round();
  if (a < 0) a = 0;
  if (a > 255) a = 255;
  return Color((a << 24) | (rgb & 0xFFFFFF));
}

int clampInt(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

double clampD(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

/// Design tokens sampled from the reference design (deep-space blue/purple/magenta + frosted glass).
class NC {
  NC._();

  static const Color space = Color(0xFF060733);
  static const Color lavender = Color(0xFFB8A2FF);
  static const Color violet = Color(0xFF8E6CF0);
  static const Color neonBlue = Color(0xFF5377F5);
  static const Color gold = Color(0xFFFFC83D);
  static const Color danger = Color(0xFFFF5A7A);
  static const Color good = Color(0xFF5CF2A5);

  static const Color glassTop = Color(0x2EFFFFFF);
  static const Color glassBottom = Color(0x12FFFFFF);
  static const Color glassBorder = Color(0x3DFFFFFF);
  static const Color textDim = Color(0xB3FFFFFF);

  static const List<Color> welcomeBg = <Color>[Color(0xFF0C2A7F), Color(0xFF2B2A93), Color(0xFF5A2E96), Color(0xFFB02A86)];
  static const List<double> welcomeStops = <double>[0.0, 0.38, 0.7, 1.0];
  static const List<Color> homeBg = <Color>[Color(0xFF0B2A6A), Color(0xFF1A1F66), Color(0xFF2A1058), Color(0xFF0C0830)];
  static const List<double> homeStops = <double>[0.0, 0.35, 0.72, 1.0];
  static const List<Color> darkBg = <Color>[Color(0xFF050833), Color(0xFF0B0D45), Color(0xFF15123F)];
  static const List<double> darkStops = <double>[0.0, 0.55, 1.0];

  static const List<Color> galaxyButton = <Color>[Color(0xFF17A7E4), Color(0xFF6A5CF0), Color(0xFFC237A8)];
}

TextStyle ts(double size, {FontWeight weight = FontWeight.w700, Color color = Colors.white, double spacing = 0, double? height, List<Shadow>? shadows}) {
  return TextStyle(fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing, height: height, shadows: shadows);
}

ThemeData buildTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF7C5CFF), brightness: Brightness.dark);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: NC.space,
  );
}
