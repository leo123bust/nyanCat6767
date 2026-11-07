import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/worlds.dart';

// Procedural art for obstacles. Everything is drawn around the origin; the caller translates.

const List<int> _candyColors = <int>[0xFFFF4081, 0xFF7C4DFF, 0xFF00BCD4, 0xFFFFC107];
const List<int> _donutFrost = <int>[0xFFFF8CC6, 0xFF9AD8FF, 0xFFFFF29A, 0xFFB69CFF];
const List<int> _sprinkles = <int>[0xFFFFFFFF, 0xFFFFE066, 0xFF66E0FF, 0xFFFF6699];
const List<int> _crystalColors = <int>[0xFFB388FF, 0xFF64FFDA, 0xFFFF80AB, 0xFF82B1FF];
const List<int> _petalColors = <int>[0xFFFF9EC7, 0xFFFFC1E3, 0xFFFFFFFF, 0xFFF48FB1];

void _disc(Canvas c, Offset o, double r, Color col) {
  c.drawCircle(o, r, Paint()..color = col);
}

Paint _stroke(Color col, double w) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..color = col;

void paintRock(Canvas canvas, int theme, double r, int variant, double t) {
  final int v = variant % 4;
  switch (theme) {
    case 1:
      _candy(canvas, r, v);
      break;
    case 2:
      _donut(canvas, r, v);
      break;
    case 3:
      _mine(canvas, r, t);
      break;
    case 4:
      _ice(canvas, r, v);
      break;
    case 5:
      _lava(canvas, r, v, t);
      break;
    case 6:
      _crystal(canvas, r, v);
      break;
    case 7:
      _gear(canvas, r, v, t);
      break;
    case 8:
      _flower(canvas, r, v);
      break;
    case 9:
      _ghost(canvas, r, t);
      break;
    case 10:
      _blackHole(canvas, r, t);
      break;
    case 11:
      _ultraOrb(canvas, r, t);
      break;
    default:
      _asteroid(canvas, r, v);
      break;
  }
}

void _asteroid(Canvas canvas, double r, int v) {
  const List<int> base = <int>[0xFF8D7B8F, 0xFF9A8C7A, 0xFF7F8FA0, 0xFFA08080];
  final Path path = Path();
  const int n = 10;
  for (int i = 0; i < n; i++) {
    final double a = i * math.pi * 2 / n;
    final double rr = r * (0.86 + 0.14 * math.sin(i * 2.7 + v));
    final double x = math.cos(a) * rr;
    final double y = math.sin(a) * rr;
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  canvas.drawPath(path, Paint()..color = Color(base[v]));
  canvas.drawPath(path, _stroke(const Color(0xFF3A2F45), 2));
  _disc(canvas, Offset(-r * 0.3, -r * 0.2), r * 0.2, const Color(0x55000000));
  _disc(canvas, Offset(r * 0.25, r * 0.3), r * 0.15, const Color(0x55000000));
  _disc(canvas, Offset(r * 0.1, -r * 0.4), r * 0.1, const Color(0x44000000));
  _disc(canvas, Offset(-r * 0.45, r * 0.25), r * 0.08, const Color(0x33FFFFFF));
}

void _candy(Canvas canvas, double r, int v) {
  final Color a = Color(_candyColors[v]);
  final Rect rect = Rect.fromCircle(center: Offset.zero, radius: r);
  _disc(canvas, Offset.zero, r, const Color(0xFFFFFFFF));
  final Paint p = Paint()..color = a;
  for (int i = 0; i < 6; i++) {
    canvas.drawArc(rect, i * math.pi / 3, math.pi / 6, true, p);
  }
  canvas.drawCircle(Offset.zero, r, _stroke(a.withAlpha(255), 2.5));
  _disc(canvas, Offset(-r * 0.35, -r * 0.4), r * 0.16, const Color(0x99FFFFFF));
}

void _donut(Canvas canvas, double r, int v) {
  canvas.drawCircle(Offset.zero, r * 0.64, _stroke(const Color(0xFFE3A25B), r * 0.72));
  canvas.drawCircle(Offset.zero, r * 0.68, _stroke(Color(_donutFrost[v]), r * 0.56));
  for (int i = 0; i < 9; i++) {
    final double a = i * 0.7 + 0.3;
    canvas.save();
    canvas.translate(math.cos(a) * r * 0.68, math.sin(a) * r * 0.68);
    canvas.rotate(a * 3);
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: r * 0.17, height: r * 0.06), Paint()..color = Color(_sprinkles[i % 4]));
    canvas.restore();
  }
}

void _mine(Canvas canvas, double r, double t) {
  final Paint spike = Paint()..color = const Color(0xFFFF2E4D);
  for (int i = 0; i < 8; i++) {
    canvas.save();
    canvas.rotate(i * math.pi / 4 + t * 0.5);
    final Path p = Path()
      ..moveTo(r * 0.75, -r * 0.14)
      ..lineTo(r * 1.0, 0)
      ..lineTo(r * 0.75, r * 0.14)
      ..close();
    canvas.drawPath(p, spike);
    canvas.restore();
  }
  _disc(canvas, Offset.zero, r * 0.82, const Color(0xFF1B1B3A));
  canvas.drawCircle(Offset.zero, r * 0.82, _stroke(const Color(0xFF5B5B9A), 2));
  final double pulse = 0.6 + 0.4 * math.sin(t * 6);
  _disc(canvas, Offset.zero, r * 0.5 * (0.8 + 0.2 * pulse), Color.fromARGB((120 + 100 * pulse).round(), 255, 46, 77));
  _disc(canvas, Offset.zero, r * 0.24, const Color(0xFFFFFFFF));
}

void _ice(Canvas canvas, double r, int v) {
  final Path hex = Path();
  for (int i = 0; i < 6; i++) {
    final double a = i * math.pi / 3 + math.pi / 6;
    final double x = math.cos(a) * r;
    final double y = math.sin(a) * r;
    if (i == 0) {
      hex.moveTo(x, y);
    } else {
      hex.lineTo(x, y);
    }
  }
  hex.close();
  canvas.drawPath(hex, Paint()..shader = ui.Gradient.linear(Offset(-r, -r), Offset(r, r), const <Color>[Color(0xFFE1F5FE), Color(0xFF4FC3F7)]));
  canvas.drawPath(hex, _stroke(const Color(0xFF0277BD), 2.5));
  final Paint line = _stroke(const Color(0xAAFFFFFF), 2);
  for (int i = 0; i < 6; i += 2) {
    final double a = i * math.pi / 3 + math.pi / 6;
    canvas.drawLine(Offset.zero, Offset(math.cos(a) * r * 0.95, math.sin(a) * r * 0.95), line);
  }
}

void _lava(Canvas canvas, double r, int v, double t) {
  _disc(canvas, Offset.zero, r * 1.25, Color.fromARGB((50 + 25 * math.sin(t * 3)).round(), 255, 110, 0));
  _disc(canvas, Offset.zero, r, const Color(0xFF3B1A12));
  canvas.drawCircle(Offset.zero, r, _stroke(const Color(0xFF1A0A06), 2));
  final Paint crack = _stroke(const Color(0xFFFF8A00), 2.5);
  canvas.drawLine(Offset(-r * 0.6, -r * 0.2), Offset(-r * 0.1, r * 0.1), crack);
  canvas.drawLine(Offset(-r * 0.1, r * 0.1), Offset(r * 0.35, -r * 0.35), crack);
  canvas.drawLine(Offset(-r * 0.1, r * 0.1), Offset(r * 0.1, r * 0.6), crack);
  canvas.drawLine(Offset(r * 0.35, -r * 0.35), Offset(r * 0.7, -r * 0.2), crack);
}

void _crystal(Canvas canvas, double r, int v) {
  final Color c = Color(_crystalColors[v]);
  final Path d = Path()
    ..moveTo(0, -r)
    ..lineTo(r * 0.72, 0)
    ..lineTo(0, r)
    ..lineTo(-r * 0.72, 0)
    ..close();
  canvas.drawPath(d, Paint()..color = c);
  final Path left = Path()
    ..moveTo(0, -r)
    ..lineTo(-r * 0.72, 0)
    ..lineTo(0, r * 0.1)
    ..close();
  canvas.drawPath(left, Paint()..color = const Color(0x66FFFFFF));
  final Path low = Path()
    ..moveTo(0, r * 0.1)
    ..lineTo(r * 0.72, 0)
    ..lineTo(0, r)
    ..close();
  canvas.drawPath(low, Paint()..color = const Color(0x33000000));
  canvas.drawPath(d, _stroke(const Color(0xFFFFFFFF), 2));
}

void _gear(Canvas canvas, double r, int v, double t) {
  const List<int> cols = <int>[0xFF00FFC6, 0xFFFF00E6, 0xFF00B0FF, 0xFFFFEA00];
  final Color c = Color(cols[v]);
  canvas.save();
  canvas.rotate(t * 0.9 * (v.isEven ? 1 : -1));
  final Paint tooth = Paint()..color = c;
  for (int i = 0; i < 10; i++) {
    canvas.save();
    canvas.rotate(i * math.pi / 5);
    canvas.drawRect(Rect.fromLTRB(r * 0.72, -r * 0.13, r, r * 0.13), tooth);
    canvas.restore();
  }
  canvas.restore();
  _disc(canvas, Offset.zero, r * 0.82, const Color(0xFF10163A));
  canvas.drawCircle(Offset.zero, r * 0.82, _stroke(c, 3));
  canvas.drawCircle(Offset.zero, r * 0.45, _stroke(c.withAlpha(150), 2));
  _disc(canvas, Offset.zero, r * 0.18, c);
}

void _flower(Canvas canvas, double r, int v) {
  final Paint petal = Paint()..color = Color(_petalColors[v]);
  for (int i = 0; i < 5; i++) {
    canvas.save();
    canvas.rotate(i * math.pi * 2 / 5);
    canvas.drawOval(Rect.fromCenter(center: Offset(0, -r * 0.5), width: r * 0.78, height: r * 0.95), petal);
    canvas.drawOval(Rect.fromCenter(center: Offset(0, -r * 0.5), width: r * 0.78, height: r * 0.95), _stroke(const Color(0x55C2185B), 1.5));
    canvas.restore();
  }
  _disc(canvas, Offset.zero, r * 0.27, const Color(0xFFFFD54F));
  _disc(canvas, Offset(-r * 0.06, -r * 0.06), r * 0.1, const Color(0xFFFFF59D));
}

void _ghost(Canvas canvas, double r, double t) {
  final Path p = Path()..moveTo(-r, 0);
  p.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
  p.lineTo(r, r * 0.8);
  for (int i = 0; i < 4; i++) {
    final double x0 = r - i * r * 0.5;
    p.quadraticBezierTo(x0 - r * 0.25, r * (0.8 + 0.3 * math.sin(t * 5 + i)), x0 - r * 0.5, r * 0.8);
  }
  p.close();
  canvas.drawPath(p, Paint()..color = const Color(0xEEEAF2FF));
  canvas.drawPath(p, _stroke(const Color(0xFF8FA8D8), 2));
  _disc(canvas, Offset(-r * 0.35, -r * 0.1), r * 0.16, const Color(0xFF1A237E));
  _disc(canvas, Offset(r * 0.35, -r * 0.1), r * 0.16, const Color(0xFF1A237E));
  canvas.drawOval(Rect.fromCenter(center: Offset(0, r * 0.3), width: r * 0.3, height: r * 0.36), Paint()..color = const Color(0xFF1A237E));
}

void _blackHole(Canvas canvas, double r, double t) {
  canvas.drawCircle(Offset.zero, r * 0.82, _stroke(const Color(0xFFFF8F00), r * 0.3));
  canvas.drawCircle(Offset.zero, r * 0.82, _stroke(const Color(0xAAFFE082), r * 0.1));
  _disc(canvas, Offset.zero, r * 0.62, const Color(0xFF000000));
  final Rect rect = Rect.fromCircle(center: Offset.zero, radius: r * 0.82);
  canvas.drawArc(rect, t * 2, 1.2, false, _stroke(const Color(0xFFFFFFFF), 3));
}

void _ultraOrb(Canvas canvas, double r, double t) {
  _disc(canvas, Offset.zero, r, const Color(0xFF1A0A3A));
  final Paint ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = r * 0.28
    ..shader = ui.Gradient.sweep(
      Offset.zero,
      const <Color>[Color(0xFFFF4DFF), Color(0xFF4DFFFF), Color(0xFFFFFF4D), Color(0xFFFF4DFF)],
      null,
      TileMode.clamp,
      t,
      t + math.pi * 2,
    );
  canvas.drawCircle(Offset.zero, r * 0.82, ring);
  _disc(canvas, Offset.zero, r * 0.42, const Color(0xFFFFFFFF));
  _disc(canvas, Offset.zero, r * 0.26, const Color(0xFFFF4DFF));
}

void paintPillar(Canvas canvas, int theme, WorldDef w, Rect rect, bool capAtBottom, double t) {
  if (rect.height <= 0) return;
  final Color a = Color(w.accent);
  final Color b = Color(w.bottom);
  final Color mid = Color.lerp(b, a, 0.55) ?? a;
  canvas.drawRect(rect, Paint()..shader = ui.Gradient.linear(rect.centerLeft, rect.centerRight, <Color>[b, mid, b], <double>[0.0, 0.5, 1.0]));
  if (theme == 1) {
    canvas.save();
    canvas.clipRect(rect);
    final Paint s = Paint()..color = const Color(0xBBFFFFFF);
    for (double y = rect.top - rect.width; y < rect.bottom + rect.width; y += 34) {
      final Path p = Path()
        ..moveTo(rect.left, y)
        ..lineTo(rect.right, y - rect.width * 0.6)
        ..lineTo(rect.right, y - rect.width * 0.6 + 14)
        ..lineTo(rect.left, y + 14)
        ..close();
      canvas.drawPath(p, s);
    }
    canvas.restore();
  } else {
    final Paint edge = _stroke(Color(w.accent2).withAlpha(170), 2);
    canvas.drawLine(Offset(rect.left + 3, rect.top), Offset(rect.left + 3, rect.bottom), edge);
    canvas.drawLine(Offset(rect.right - 3, rect.top), Offset(rect.right - 3, rect.bottom), edge);
  }
  const double capH = 22;
  final Rect cap = capAtBottom
      ? Rect.fromLTWH(rect.left - 6, rect.bottom - capH, rect.width + 12, capH)
      : Rect.fromLTWH(rect.left - 6, rect.top, rect.width + 12, capH);
  final RRect rr = RRect.fromRectAndRadius(cap, const Radius.circular(8));
  canvas.drawRRect(rr, Paint()..color = Color.lerp(a, const Color(0xFFFFFFFF), 0.25) ?? a);
  canvas.drawRRect(rr, _stroke(const Color(0x66000000), 2));
  if (theme == 4) {
    final Paint sp = Paint()..color = const Color(0xFFE1F5FE);
    final double y0 = capAtBottom ? cap.bottom : cap.top;
    final double dir = capAtBottom ? 1.0 : -1.0;
    for (double x = cap.left + 4; x < cap.right - 8; x += 14) {
      final Path p = Path()
        ..moveTo(x, y0)
        ..lineTo(x + 7, y0 + dir * 14)
        ..lineTo(x + 14, y0)
        ..close();
      canvas.drawPath(p, sp);
    }
  }
}

/// [state]: 0 off, 1 warning, 2 on.
void paintLaser(Canvas canvas, WorldDef w, Rect beam, int state, double t) {
  final Color a = Color(w.accent);
  final double cy = beam.center.dy;
  final double th = beam.height;
  if (state == 2) {
    canvas.drawRect(beam.inflate(th * 0.9), Paint()
      ..color = a.withAlpha(95)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawRect(beam, Paint()..color = a);
    canvas.drawRect(Rect.fromLTRB(beam.left, cy - th * 0.22, beam.right, cy + th * 0.22), Paint()..color = const Color(0xFFFFFFFF));
  } else if (state == 1) {
    final double pulse = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * 30));
    canvas.drawRect(Rect.fromLTRB(beam.left, cy - 1.5, beam.right, cy + 1.5), Paint()..color = a.withAlpha((210 * pulse).round()));
  } else {
    final Paint dot = Paint()..color = a.withAlpha(60);
    for (double x = beam.left; x < beam.right; x += 16) {
      canvas.drawRect(Rect.fromLTWH(x, cy - 1, 6, 2), dot);
    }
  }
  for (final double x in <double>[beam.left, beam.right]) {
    _disc(canvas, Offset(x, cy), th * 0.95, const Color(0xFF20204A));
    _disc(canvas, Offset(x, cy), th * 0.5, state == 2 ? const Color(0xFFFFFFFF) : a);
  }
}

void paintSpinner(Canvas canvas, WorldDef w, double armLen, double ballR, double angle) {
  final Color a = Color(w.accent);
  canvas.save();
  canvas.rotate(angle);
  final RRect arm = RRect.fromRectAndRadius(Rect.fromLTRB(-armLen, -7, armLen, 7), const Radius.circular(7));
  canvas.drawRRect(arm, Paint()..color = const Color(0xFF2A2455));
  canvas.drawRRect(arm, _stroke(a, 2));
  for (final double s in <double>[-1, 1]) {
    final Offset c = Offset(armLen * s, 0);
    _disc(canvas, c, ballR + 5, a.withAlpha(70));
    _disc(canvas, c, ballR, a);
    _disc(canvas, c, ballR * 0.45, const Color(0xFFFFFFFF));
  }
  canvas.restore();
  _disc(canvas, Offset.zero, 12, const Color(0xFF14102E));
  _disc(canvas, Offset.zero, 7, a);
}
