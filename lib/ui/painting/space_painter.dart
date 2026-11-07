import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/clock.dart';

class NebulaBlob {
  const NebulaBlob(this.fx, this.fy, this.fr, this.color);

  final double fx;
  final double fy;
  final double fr;
  final int color;
}

class _Star {
  const _Star(this.x, this.y, this.size, this.phase, this.speed);

  final double x;
  final double y;
  final double size;
  final double phase;
  final double speed;
}

class _SpacePainter extends CustomPainter {
  _SpacePainter(this.colors, this.stops, this.nebula, this.icons, int starCount, int seed) : super(repaint: AppClock.t) {
    final math.Random r = math.Random(seed);
    for (int i = 0; i < starCount; i++) {
      _stars.add(_Star(r.nextDouble(), r.nextDouble(), 1.0 + r.nextDouble() * 2.0, r.nextDouble() * 6.28, 0.6 + r.nextDouble() * 1.8));
    }
  }

  final List<Color> colors;
  final List<double> stops;
  final List<NebulaBlob> nebula;
  final bool icons;
  final List<_Star> _stars = <_Star>[];

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, colors, stops));
    for (final NebulaBlob b in nebula) {
      final Offset c = Offset(size.width * b.fx, size.height * b.fy);
      final double r = size.width * b.fr;
      final Color col = Color(b.color);
      canvas.drawCircle(c, r, Paint()..shader = ui.Gradient.radial(c, r, <Color>[col.withAlpha(90), col.withAlpha(0)], <double>[0.0, 1.0]));
    }
    final double t = AppClock.t.value;
    final Paint sp = Paint()..isAntiAlias = false;
    for (final _Star s in _stars) {
      final double a = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(t * s.speed + s.phase));
      sp.color = Color.fromARGB((a * 255).round(), 255, 255, 255);
      canvas.drawRect(Rect.fromLTWH(s.x * size.width, s.y * size.height, s.size, s.size), sp);
    }
    if (icons) _paintIcons(canvas, size);
  }

  void _planet(Canvas canvas, Offset c, double r, double tilt, Paint line) {
    canvas.drawCircle(c, r, line);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(tilt);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 2.7, height: r * 0.8), line);
    canvas.restore();
  }

  void _constellation(Canvas canvas, List<Offset> pts, Paint line) {
    final Path path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, line);
    for (final Offset p in pts) {
      canvas.drawCircle(p, 3.2, line);
    }
  }

  void _paintIcons(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0x2EFFFFFF);
    _planet(canvas, Offset(w * 0.13, h * 0.1), 20, -0.4, line);
    _planet(canvas, Offset(w * 0.86, h * 0.14), 26, -0.35, line);
    _planet(canvas, Offset(w * 0.84, h * 0.94), 22, 0.4, line);
    _constellation(canvas, <Offset>[Offset(w * 0.78, h * 0.37), Offset(w * 0.86, h * 0.42), Offset(w * 0.93, h * 0.36), Offset(w * 0.9, h * 0.46)], line);
    _constellation(canvas, <Offset>[Offset(w * 0.1, h * 0.9), Offset(w * 0.2, h * 0.86), Offset(w * 0.27, h * 0.92)], line);
    final Path star = Path()
      ..moveTo(w * 0.09, h * 0.2 - 9)
      ..lineTo(w * 0.09 + 2, h * 0.2 - 2)
      ..lineTo(w * 0.09 + 9, h * 0.2)
      ..lineTo(w * 0.09 + 2, h * 0.2 + 2)
      ..lineTo(w * 0.09, h * 0.2 + 9)
      ..lineTo(w * 0.09 - 2, h * 0.2 + 2)
      ..lineTo(w * 0.09 - 9, h * 0.2)
      ..lineTo(w * 0.09 - 2, h * 0.2 - 2)
      ..close();
    canvas.drawPath(star, line);
  }

  @override
  bool shouldRepaint(_SpacePainter old) => old.colors != colors || old.icons != icons;
}

/// Animated deep-space background (gradient + twinkling pixel stars + nebula glows).
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({
    super.key,
    required this.colors,
    required this.stops,
    this.nebula = const <NebulaBlob>[],
    this.icons = false,
    this.starCount = 70,
    this.seed = 3,
    this.child,
  });

  final List<Color> colors;
  final List<double> stops;
  final List<NebulaBlob> nebula;
  final bool icons;
  final int starCount;
  final int seed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        RepaintBoundary(
          child: CustomPaint(painter: _SpacePainter(colors, stops, nebula, icons, starCount, seed)),
        ),
        if (child != null) child!,
      ],
    );
  }
}
